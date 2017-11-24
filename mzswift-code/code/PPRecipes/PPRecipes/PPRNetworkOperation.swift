import Foundation
import CoreData

class PPRNetworkOperation: Operation, URLSessionDataDelegate {

  var startTimeInterval: TimeInterval?
  var operationRunTime: TimeInterval?

  override func start() {
    if isCancelled {
      isFinished = true
      return
    }

    startTimeInterval = Date.timeIntervalSinceReferenceDate

    let url = URL(string: "a url to some JSON data")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    sessionTask = localURLSession.dataTask(with: request)
    sessionTask!.resume()
  }

  init(context: NSManagedObjectContext) {
    managedObjectContext = context
    super.init()
  }

  var managedObjectContext: NSManagedObjectContext

  //MARK: Variables

  var sessionTask: URLSessionTask?
  var incomingData = NSMutableData()

  var localConfig: URLSessionConfiguration {
    return URLSessionConfiguration.default
  }

  var localURLSession: URLSession {
    return URLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
  }

  var localFinished: Bool = false
  override var isFinished: Bool {
    get {
      return localFinished
    }
    set (newAnswer) {
      willChangeValue(forKey: "isFinished")
      localFinished = newAnswer
      didChangeValue(forKey: "isFinished")
    }
  }

  func constructRecipeFromJSON(_ json: [String: AnyObject], moc: NSManagedObjectContext) {
    let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: moc)
    recipe.setValue("Test", forKey:"name")
    //Use data from JSON to populate the recipe
  }

  func processData() throws {
    if incomingData.length == 0 {
      print("No data received")
      return
    }
    let id = incomingData
    let json = try JSONSerialization.jsonObject(with: id as Data, options: [])
    guard let collection = json as? [[String: AnyObject]] else {
      fatalError("Unexpected JSON Structure: \(json)")
    }

    let t = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
    let moc = NSManagedObjectContext(concurrencyType: t)
    moc.parent = managedObjectContext

    moc.performAndWait {
      for jsonObject in collection {
        self.constructRecipeFromJSON(jsonObject, moc: moc)
      }
    }

    moc.performAndWait {
      do {
        try moc.save()
      } catch {
        fatalError("Failed to save child context: \(error)")
      }
    }
  }

  //MARK: NSURLSessionTaskDelegate

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
    didReceive response: URLResponse,
    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
      if isCancelled {
        isFinished = true
        sessionTask?.cancel()
        return
      }
      //TODO: Check the response code and react appropriately
      completionHandler(.allow)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
    didReceive data: Data) {
      if isCancelled {
        isFinished = true
        sessionTask?.cancel()
        return
      }
      incomingData.append(data)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask,
    didCompleteWithError error: Error?) {
      if isCancelled {
        isFinished = true
        sessionTask?.cancel()
        return
      }
      if error != nil {
        print("Failed to receive response: \(error)")
        isFinished = true
        return
      }
      do {
        try processData()
      } catch {
        print("Error processing data: \(error)")
      }
      isFinished = true
      let end = Date.timeIntervalSinceReferenceDate
      if let startTimeInterval = startTimeInterval {
        operationRunTime = end - startTimeInterval
      }
  }
  
}
