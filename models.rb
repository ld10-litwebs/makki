ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")

class User <ActiveRecord::Base
    has_secure_password
    validates :mail,
    presence: true,
    format: {with:/.+@.+/}
validates :password,
    length: {in: 5..10}
end

class Review <ActiveRecord::Base
    belongs_to :user
    belongs_to :lesson
    belongs_to :university
    
end

class User <ActiveRecord::Base
    has_many :reviews
    has_many :lessons, :through => :reviews
    belongs_to :university
end

class Lesson <ActiveRecord::Base
    has_many :users, :through => :reviews
    has_many :reviews
    belongs_to :university
end

class University <ActiveRecord::Base
    has_many :users, :through => :reviews
    has_many :reviews
    has_many :lessons, :through => :reviews
end