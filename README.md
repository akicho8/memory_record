# MemoryRecord

[![Build Status](https://travis-ci.org/akicho8/memory_record.svg?branch=master)](https://travis-ci.org/akicho8/memory_record)
[![Gem Version](https://badge.fury.io/rb/memory_record.svg)](https://badge.fury.io/rb/memory_record)

<!-- [![Dependency Status](https://gemnasium.com/badges/github.com/akicho8/memory_record.svg)](https://gemnasium.com/github.com/akicho8/memory_record) -->

## Introduction

A simple library that handles a few records easily.
With this library can flexibly managed immutable data.

## Installation

Install as a standalone gem

```shell
$ gem install memory_record
```

Or install within application using Gemfile

```shell
$ bundle add memory_record
$ bundle install
```

## Examples

### Basic usage

```ruby
class Palette
  include MemoryRecord
  memory_record [
    { key: :coral,  r: 255, g: 127, b:   0 },
    { key: :tomato, r: 255, g:  99, b:  71 },
    { key: :gold,   r: 255, g: 215, b:   0 },
  ]

  def rgb
    [r, g, b]
  end

  def hex
    "#" + rgb.collect { |e| "%02X" % e }.join
  end

  def name
    super.capitalize
  end
end

Palette[:tomato].key   # => :tomato
Palette[:tomato].name  # => "Tomato"
Palette[:tomato].rgb   # => [255, 99, 71]
Palette[:tomato].hex   # => "#FF6347"
Palette.collect(&:hex) # => ["#FF7F00", "#FF6347", "#FFD700"]
```

### How to turn as an array?

**Enumerable** extended, so that **each** method is available

```ruby
Palette.each { |e| ... }
Palette.collect { |e| ... }
```

### How do I submit a form to select in Rails?

```ruby
form.collection_select(:selection_code, Palette, :code, :name)
```

### Is the reference in subscripts slow?

Since it has a hash internally using the key value as a key, it can be acquired with O (1).

```ruby
Palette[1].name       # => "Tomato"
Palette[:tomato].name # => "Tomato"
```

### Instances always react to **code** and **key**

```ruby
object = Palette[:tomato]
object.key  # => :tomato
object.code # => 1
```

### How do I add a method to an instance?

For that, I am creating a new class so I need to define it normally

### **name** method is special?

If **name** is not defined, it defines a **name** method that returns **key.to_s**

### **to_s** method is defined?

Alias of **name**, **to_s** is defined.

### If there is no key, use fetch to get an error

```ruby
Palette.fetch(:xxx)              # => <KeyError: ...>
```

The following are all the same

```ruby
Palette[:xxx] || :default        # => :default
Palette.fetch(:xxx, :default}    # => :default
Palette.fetch(:xxx) { :default } # => :default
```

### Use fetch_if to ignore if the key is nil

```ruby
Palette.fetch_if(nil)            # => nil
Palette.fetch_if(:tomato)        # => #<Palette:... @attributes={...}>
Palette.fetch_if(:xxx)           # => <KeyError: ...>
```

### How to refer to other keys

```ruby
class Foo
  include MemoryRecord
  memory_record [
    { key: :a, other_key: :x },
    { key: :b, other_key: :y },
    { key: :c, other_key: :z },
  ]

  class << self
    def lookup(v)
      super || invert_table[v]
    end

    private

    def invert_table
      @invert_table ||= inject({}) {|a, e| a.merge(e.other_key => e) }
    end
  end
end

Foo[:a] == Foo[:x]                  # => true
Foo[:b] == Foo[:y]                  # => true
Foo[:c] == Foo[:z]                  # => true
```

### How prohibit the hash key from being attr_reader automatically?

Use `attr_reader: false` or `attr_reader: {only: ...}` or `attr_reader: {except: ...}`

```ruby
class Foo
  include MemoryRecord
  memory_record attr_reader: {only: :y} do
    [
      { x: 1, y: 1, z: 1 },
    ]
  end
end

Foo.first.x rescue $! # => #<NoMethodError: undefined method `x' for #<Foo:0x007fcc861ff108>>
Foo.first.y rescue $! # => 1
Foo.first.z rescue $! # => #<NoMethodError: undefined method `z' for #<Foo:0x007fcc861ff108>>
```

### How to decide **code** yourself?

```ruby
class Foo
  include MemoryRecord
  memory_record [
    { code: 1, key: :a, name: "A" },
    { code: 2, key: :b, name: "B" },
  ]
end

Foo.collect(&:code) # => [1, 2]
```

It is not recommended to specify it explicitly.
It is useful only when refactoring legacy code with compatibility in mind.

### Convert to JSON

Similar to ActiveModel's serialization, there is an `only` `except` `methods` `include` method.

```ruby
class ColorInfo
  include MemoryRecord
  memory_record [
    { key: :blue, rgb: [  0, 0, 255], },
    { key: :red,  rgb: [255, 0,   0], },
  ]

  def hex
    "#" + rgb.collect { |e| "%02X" % e }.join
  end

  def children
    [
      {x: 1, y: 2},
      {x: 3, y: 4},
    ]
  end
end

color_info = ColorInfo.first
color_info.as_json(only: :key)              # => {:key => :blue}
color_info.as_json(except: [:rgb, :code])   # => {:key => :blue}
color_info.as_json(only: [], methods: :hex) # => {:hex => "#0000FF"}
color_info.as_json(only: [], include: {children: {only: :x}} ) # => {:children => [{"x" => 1}, {"x" => 3}]}

ColorInfo.as_json(only: :key)               # => [{:key=>:blue}, {:key=>:red}]
```
