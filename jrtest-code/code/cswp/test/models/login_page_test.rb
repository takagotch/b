#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
require 'test_helper'

class LoginPageTest

  def test_authentication_with_valid_credentials_should_have_signout_link
  end

  def test_authentication_with_invalid_credentials_should_not_have_error_message
  end

  def test_authentication_with_valid_credentials_should_have_correct_title
  end

  def test_authentication_with_invalid_credentials_should_have_signin_link
  end

  def test_authentication_with_invalid_credentials_should_have_error_message
  end

end

class LoginPageTest

  # valid credentials

  def test_authentication_with_valid_credentials_should_have_signout_link
  end

  def test_authentication_with_valid_credentials_should_have_correct_title
  end

  # invalid credentials

  def test_authentication_with_invalid_credentials_should_not_have_error_message
  end

  def test_authentication_with_invalid_credentials_should_have_signin_link
  end

  def test_authentication_with_invalid_credentials_should_have_error_message
  end

end

class LoginAuthenticationPageTest

  # valid credentials

  def valid_credentials_should_have_signout_link
  end

  def valid_credentials_should_have_correct_title
  end

  # invalid credentials

  def invalid_credentials_should_not_have_error_message
  end

  def invalid_credentials_should_have_signin_link
  end

  def invalid_credentials_should_have_error_message
  end

end

class LoginAuthenticationPageTest

  # class valid_credential_tests

    def should_have_signout_link
    end

    def should_have_correct_title
    end

  # end

  # class invalid_credential_tests

    def should_not_have_error_message
    end

    def should_have_signin_link
    end

    def should_have_error_message
    end

  # end

end

#
# describe 'Authentication' do
#
#   describe 'signin' do
#
#     describe 'with valid credentials' do
#       describe 'followed by signout' do
#       end
#     end
#
#     describe 'with invalid credentials' do
#       describe 'followed by visiting another page' do
#       end
#     end
#
#   end
#
# end
