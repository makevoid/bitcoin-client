module BitcoinClient
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 4
    REL = nil
    
    STRING = REL ? [MAJOR, MINOR, PATCH, REL].join('.') : [MAJOR, MINOR, PATCH].join('.')
  end
  
  VERSION = Version::STRING
end
