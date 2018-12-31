# Arpry

Pry with Active Record. Without Rails.

## What's this?

Rails Console is a powerful tool for exploring database, but it works only with Rails.

Arpry works like Rails Console without Rails.
You can get the same experience as Rails Console to explore database with not-Rails project!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arpry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arpry

## Usage

Explore database with `arpry` command.

```bash
# For sqlite3
$ arpry /path/to/databasefile.sqlite3

# For postgresql
$ arpry --adapter postgresql --host localhost --user YOUR_USER_NAME --password YOUR_PASSWORD --database YOUR_DB_NAME
```

See `arpry --help` for more information of command line options.


Arpry defines classes for each table. For example:

```ruby
[1] pry(Arpry::Namespace)> User.first
D, [2018-12-31T22:07:45.652956 #8470] DEBUG -- :   Arpry::Namespace::User Load (0.2ms)  SELECT  "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
=> #<Arpry::Namespace::User:0x000056057e2404a8 id: 42, name: "pocke">
```

Arpry defines has_many, belongs_to, and has_many through relations automatically. For example:

```sql
-- test.sqlite3

-- Schema
CREATE TABLE articles ( id int primary key not null, title text not null, content text not null);
CREATE TABLE comments ( id int primary key not null, article_id int not null, content text not null);
CREATE TABLE tags ( id int primary key not null, name text not null);
CREATE TABLE article_tags ( id int primary key not null, article_id int not null, tag_id int not null);

-- Data
INSERT INTO articles(id, title, content) VALUES (1, 'Awesome Article', 'Hello, world!');
INSERT INTO comments(id, article_id, content) VALUES (1, 1, 'It is fantastic!');
INSERT INTO tags(id, name) VALUES (1, 'tech'), (2, 'hobby'), (3, 'game');
INSERT INTO article_tags(id, article_id, tag_id) VALUES (1, 1, 1), (2, 1, 2);
```

```bash
$ sqlite3 db < test.sqlite3
```

```ruby
$ arpry db
[1] pry(Arpry::Namespace)> a = Article.first
D, [2018-12-31T22:27:02.801294 #10176] DEBUG -- :   Arpry::Namespace::Article Load (0.2ms)  SELECT  "articles".* FROM "articles" ORDER BY "articles"."id" ASC LIMIT ?  [["LIMIT", 1]]
=> #<Arpry::Namespace::Article:0x000055d1066d6fa0 id: 1, title: "Awesome Article", content: "Hello, world!">
[2] pry(Arpry::Namespace)> a.comments
D, [2018-12-31T22:27:08.291179 #10176] DEBUG -- :   Arpry::Namespace::Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
=> [#<Arpry::Namespace::Comment:0x000055d10684cb78 id: 1, article_id: 1, content: "It is fantastic!">]
[3] pry(Arpry::Namespace)> a.tags
D, [2018-12-31T22:27:11.505179 #10176] DEBUG -- :   Arpry::Namespace::Tag Load (0.2ms)  SELECT "tags".* FROM "tags" INNER JOIN "article_tags" ON "tags"."id" = "article_tags"."tag_id" WHERE "article_tags"."article_id" = ?  [["article_id", 1]]
=> [#<Arpry::Namespace::Tag:0x000055d105f6b2c0 id: 1, name: "tech">, #<Arpry::Namespace::Tag:0x000055d105f6b018 id: 2, name: "hobby">]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pocke/arpry.
