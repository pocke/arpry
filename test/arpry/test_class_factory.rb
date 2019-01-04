require 'test_helper'

class TestRunner < Minitest::Test
  def test_sqlite3
    sql = <<~SQL
      CREATE TABLE articles ( id int primary key not null, title text not null, content text not null);
      CREATE TABLE comments ( id int primary key not null, article_id int not null, content text not null);
      CREATE TABLE tags ( id int primary key not null, name text not null);
      CREATE TABLE article_tags ( id int primary key not null, article_id int not null, tag_id int not null);

      INSERT INTO articles(id, title, content) VALUES (1, 'Awesome Article', 'Hello, world!');
      INSERT INTO comments(id, article_id, content) VALUES (1, 1, 'It is fantastic!');
      INSERT INTO comments(id, article_id, content) VALUES (2, 1, 'It is awesome!');
      INSERT INTO tags(id, name) VALUES (1, 'tech'), (2, 'hobby'), (3, 'game');
      INSERT INTO article_tags(id, article_id, tag_id) VALUES (1, 1, 1), (2, 1, 2);
    SQL
    path = Pathname(__dir__) / '../../tmp/test-db'
    IO.popen(['sqlite3', path.to_s], 'r+') do |io|
      io.write(sql)
      io.close
    end

    n = Arpry::ClassFactory.create(adapter: 'sqlite3', database: path.to_s)
    assert_equal n::Article.first.title, 'Awesome Article'

    assert_equal 2, n::Article.first.comments.count
    assert_equal 2, n::Article.first.tags.count
    assert_equal n::Comment.first.article, n::Article.first
  ensure
    path&.delete
  end

  def test_sqlite3_fk
    fk1 = 'c' + SecureRandom.hex(10)
    fk2 = 'c' + SecureRandom.hex(10)
    fk3 = 'c' + SecureRandom.hex(10)
    sql = <<~SQL
      CREATE TABLE articles ( id int primary key not null, title text not null, content text not null);
      CREATE TABLE comments ( id int primary key not null, #{fk1} int not null, content text not null,
                              FOREIGN KEY(#{fk1}) REFERENCES articles(id));
      CREATE TABLE tags ( id int primary key not null, name text not null);
      CREATE TABLE article_tags ( id int primary key not null, #{fk2} int not null, #{fk3} int not null,
                                  FOREIGN KEY(#{fk2}) REFERENCES articles(id),
                                  FOREIGN KEY(#{fk3}) REFERENCES tags(id));

      INSERT INTO articles(id, title, content) VALUES (1, 'Awesome Article', 'Hello, world!');
      INSERT INTO comments(id, #{fk1}, content) VALUES (1, 1, 'It is fantastic!');
      INSERT INTO comments(id, #{fk1}, content) VALUES (2, 1, 'It is awesome!');
      INSERT INTO tags(id, name) VALUES (1, 'tech'), (2, 'hobby'), (3, 'game');
      INSERT INTO article_tags(id, #{fk2}, #{fk3}) VALUES (1, 1, 1), (2, 1, 2);
    SQL
    path = Pathname(__dir__) / '../../tmp/test-db'
    IO.popen(['sqlite3', path.to_s], 'r+') do |io|
      io.write(sql)
      io.close
    end

    n = Arpry::ClassFactory.create(adapter: 'sqlite3', database: path.to_s)
    assert_equal n::Article.first.title, 'Awesome Article'

    assert_equal 2, n::Article.first.comments.count
    assert_equal 2, n::Article.first.tags.count
    assert_equal n::Comment.first.article, n::Article.first
  ensure
    path&.delete
  end
end
