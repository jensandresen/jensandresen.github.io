---
title: "Implementing DDD Series: Persisting Value Objects using Entity Framework"
description: This article explores how to persist Value Objects in .NET and C# using Entity Framework. It covers their role in Domain-Driven Design, the challenges of mapping them to relational databases, and how techniques like ValueConverter can help bridge the gap between the domain model and the persistence layer.
summary: A look at persisting Value Objects in Domain-Driven Design with Entity Framework, focusing on practical implementation in C#. See how I like to map Value Objects to relational databases while maintaining business invariants and promoting clarity for developers.
published: 2025-01-20
draft: false
tags: ["DDD", "Domain-Driven Design", ".NET", "C#", "Entity Framework"]
categories: ["Development", "Design"]
images: ["/img/persisting-values-1.jpg"]
keywords: ["DDD", "Domain-Driven Design", "Value Objects"]
---

![Building Blocks](/img/persisting-values-1.jpg)

Following up on my previous article on [Modelling Business Primitives With `Value Objects`](https://www.jensandresen.com/blog/implementing-ddd-series-modelling-business-primitives-with-value-objects/), where I showed how I like to encapsulate the inner value and protect it at all cause, and not directly expose it to external parties (external to the `Value Object` class). This of course poses a challenge when needing to persist the value, as I've effectively introduced a whole new type that is unknown to any libraries and frameworks, and its inner value is guarded.

Let's take a look at how I often persist `Value Objects` in a typical business application, where `Entity Framework` is used on top of a relational database, business concepts are mapped to tables and columns inside those tables. In the case of `Value Objects`, they are mapped to one or more columns depending on the amount of information they carry. These columns have a data type, and we now step into the art of mapping types from the application layer to the types that are available from the persistence layer. To be fair, `Entity Framework` provides abstractions for the specific data types available in the database technology that we've chosen, but these abstractions can only be mapped back and forth between language primitives (e.g. your `string`, `int`, `bool`, `datetime` etc.) and not your newly defined business primitives in the form of `Value Objects`. And to make it worse, one of the ideas of the `Value Object` implementation is to **hide** the language primitive, so `Entity Framework` will have a hard time figuring out what to do, so we need to provide a bit of help. 

## ValueConverter to the rescue
A feature of `Entity Framework` is that you can specify a `ValueConverter` for types where you explicitly define how a language (or runtime) type should be converted to a database type. Common use cases are to force all `datetime` to be stored as UTC or to store `enum`s as their string representation to make stored values more relatable when looking directly in the database (seeing a `1` or `3` might not be as relatable as seeing `Pending` or `Failed` in a status column). 

Let's use a `ValueConverter` to tell how `Entity Framework` should convert a `Value Object` into a database type. I like to be very explicit in my `DbContext` implementations around how I tell the story of how an entity gets mapped from an object representation to a relational format, and I tend to favor explicit declarations for each property in my `OnModelCreating` override. As per my experience, it makes it easier and a lot faster to build up an understanding of how business concepts are represented in a relational format, but `Entity Framework` comes with a lot of conventions built-in and I could leave a lot of the statements out because they would get picked up by those conventions. So this is not only serving the purpose of instructing `Entity Framework` on how to persist information in a relational format, but also by being very explicit in telling the story to other developers looking at the code (and often just a future version of myself).

One way of explicitly instructing `Entity Framework` on how to convert a `Value Object` based property is to use the inline `HasConversion` option when mapping properties of an entity in the `OnModelCreating` override in your `DbContext` implementation, but if you have multiple properties of the same `Value Object` type you are better served by overriding the `ConfigureConventions` method. Then you can define a converter for all references to a type of that `Value Object`. Now these converters can be defined using inline lambda expressions to quickly get it going, but I tend to opt for a class-based approach (personal taste). In my article [Modelling Business Primitives With `Value Objects`](https://www.jensandresen.com/blog/implementing-ddd-series-modelling-business-primitives-with-value-objects/) I have implemented a `ProductNumber` as a `Value Object`, and let's instruct `Entity Framework` on how to deal with it.

### Simple ProductNumberConverter implementation
First off, I write a simple converter implementation for my `Value Object` and in this case I would write the following for converting the `ProductNumber`:

```csharp
public class ProductNumberConverter : ValueConverter<ProductNumber, string>
{
    public ProductNumberConverter() : base(
        modelValue => modelValue.ToString(),
        dbValue => ProductNumber.Parse(dbValue))
    {

    }
}
```

You can see that the `ValueConverter<>` is generic and it closes a type reference to the model type and the database type. In the case of the above my model type is my `Value Object` of `ProductNumber` and the database type is the type abstraction that `Entity Framework` understands, which in this case is a simple language primitive of `string`. The constructor of the `ValueConverter` class takes a lambda for converting from the model representation in the form of:

```csharp
modelValue => modelValue.ToString()
```

...and it also takes a lambda for converting from the database type (e.g. a `string` in this example) to a model representation in the form of:
```csharp
dbValue => ProductNumber.Parse(dbValue)
```

I rely on the parsing logic that I've implemented in the `ProductNumber` class, hence I'm pushing the responsibility onto that class where I want to centralize the logic and opinions around product numbers.

### Using the converter
Now I can specify that for all references to a type of `ProductNumber`, I want my converter to be used. I do that my adding to my override of `ConfigureConventions` method on my `DbContext` like this:

```csharp
public class PaymentApiDbContext : DbContext
{
    // ...

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        // ...

        configurationBuilder
            .Properties<ProductNumber>()
            .HaveConversion<ProductNumberConverter>();
    }
}
```

When reading the example above, it almost explains to me in *plain English* how product numbers are handled (or maybe I've just looked at this for too long 😊).

## Final thoughts
Being explicit when declaring how your information will be persisted has been a preferred practice of mine for a long time. When relying on conventions, sometimes you get too little or way too much, but being explicit about it hopefully gives you what you need. But the more important aspect of it, to me at least, is the communication of intent. You simply declare your intent; for future readers. Now conventions absolutely has its merits, and I use conventions in many places, but my experience has taught me that this is a very good place to invest a bit of extra time on being explicit. The examples above would also reveal the relative low effort and low complexity of doing so.

*Thank you for reading this post.*