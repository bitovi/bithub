class ServiceError < StandardError; end

class ConfigError < ServiceError; end
class AuthError < ServiceError; end
class RemoteError < ServiceError; end
class UnknownError < ServiceError; end
