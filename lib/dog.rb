class Dog
  attr_reader :id
  attr_accessor :name, :breed

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
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
     self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE id = ?
    SQL

    found = DB[:conn].execute(sql, id)
    id = found[0][0]
    name = found[0][1]
    breed = found[0][2]

    Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT id, name, breed
      FROM dogs
      WHERE name = ?, breed = ?
    SQL

    found = DB[:conn].execute(sql, name, breed)

    id = found[0][0]
    name = found[0][1]
    breed = found[0][2]

    self.create(name: name, breed: breed)
  end

end
