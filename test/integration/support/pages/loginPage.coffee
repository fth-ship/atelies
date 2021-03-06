HomeLayout = require './homeLayout'

module.exports = class LoginPage extends HomeLayout
  url: 'account/login'
  setFieldsAs: (values) =>
    @type "#loginForm #email", values.email
    @type "#loginForm #password", values.password
  clickLoginButton: @::pressButtonAndWait.partial "#loginForm #login"
  errors: @::getText.partial '#errors > li'
  hasErrors: @::hasElement.partial '#errors > li'
  emailRequired: @::getText.partial "#loginForm label[for=email]"
  passwordRequired: @::getText.partial "#loginForm label[for=password]"
  showsCaptcha: @::hasElementAndIsVisible.partial '.recaptcha'
  loginWith: (values, cb) ->
    @setFieldsAs values
    @clickLoginButton cb
  navigateAndLoginWith: (user, cb) ->
    @visit()
    @loginWith user, cb
