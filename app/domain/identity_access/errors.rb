module IdentityAccess::Errors
  Error = Class.new(StandardError)
  MissingCredentials = Class.new(Error)
  InvalidCredentials = Class.new(Error)
  AccessDenied = Class.new(Error)
  ExpiredCredentials = Class.new(Error)
  Misconfigured = Class.new(Error)
end
