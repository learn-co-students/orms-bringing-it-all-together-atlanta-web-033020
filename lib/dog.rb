class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed     
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        # binding.pry
        self
    end

    def self.create(attributes)
        pup = Dog.new(attributes)
        pup.save
    end

    def self.new_from_db(row)
        pup = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(pup_hash)
        search = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",pup_hash[:name], pup_hash[:breed])[0]
        if !search
            pup = Dog.create(pup_hash)
        elsif !search.empty?
            pup = new_from_db(search)
        end
        pup
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        DB[:conn].execute(sql, name).map do |row|
            Dog.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end