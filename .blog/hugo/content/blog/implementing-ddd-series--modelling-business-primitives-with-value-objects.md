---
title: "Implementing DDD Series: Modelling Business Primitives with Value Objects"
description: This article explores how to model and implement business primitives as Value Objects in .NET and C#. It discusses their role in Domain-Driven Design, how they differ from entities, and their impact on both technical design and team communication.
summary: A look at Value Objects in Domain-Driven Design, including their implementation in C#, their purpose in extending the type system, and how they help protect business invariants while fostering a shared language between developers and domain experts.
published: 2025-01-09
draft: true
tags: ["DDD", "Domain-Driven Design", ".NET", "C#"]
categories: ["Development", "Design"]
images: ["/img/building-blocks-1.jpg"]
keywords: ["DDD", "Domain-Driven Design", "Value Objects"]
---

![Building Blocks](/img/building-blocks-1.jpg)

Let's take a look at one of the fundamental *building blocks* of tactical **Domain-Driven Design**, namely `Value Objects`. Value objects are a highly useful way of implementing business information that is important within the domain your are modelling, and it gives you a place to encapsulate and protect the invariant(s) that make up that piece of business information. This is what often is referred to as *business primitives*.

From the **Domain-Driven Design** inspired literature `Value Objects` are often described by how they are identified and compared and the semantics around that, and in contrast to `Entities` that carry their identity as a **property** of the entity itself, `Value Objects` are identified by the properties they carry. So - semantically - two `Value Objects` are considered identical if the value of their properties are equal, whereas `Entities` are considered identical if the value of their identity property is equal.

To me `Value Objects` are more than just a way to represent a business value in source code. If that was the only purpose, you have plenty of language primitives already in most modern programming languages, and C# (which the following examples will be based on) is no exception to that. But you get a lot more when opting for a `Value Object`. Besides the usual encapsulation and protection of invariant(s), single and coherent place to put business rules and business opinions about that particular piece of business information, I've also come to appreciate the communication aspect of implementing `Value Objects` in source code in a very explicit manner. This then signals to future developers having to maintain the codebase that this piece of information is important to the business and to the domain. So whenever I come across a C# class that somehow indicates that this is a `Value Object` it tells me that this is an important concept in the domain and it is worth remembering, and by reading the class and hopefully the unit tests supporting it I should get a good understanding about business rules - okay granted, it will just be a tiny fraction of the domain and the business, but it should equip me with a *"context adapted vocabulary"* that I can use to have valuable conversation with domain experts and to start building up a **Ubiquitous Language**. I find this communication aspect of it sooooo cool and really really useful! Just think of the implicit (and convention based) contract between developers working in the codebase where it signals that this class (read *information*) is important. It's subtle, but makes a huge difference!

## Let's write one
Okay, so with that in mind, let's look at some code. Now I've used `Value Objects` for a long time, and I have experimented with different ways of implementing the same thing. I've used language constructs from C# that might seem like a good fit (e.g. `struct`, `record` and just simple POCO's), and they all have their advantages like built-in semantical equality but there is always something that I have to do to it to make it behave in a way that proper encapsulates and protects the invariants the way I want it to. So I always gravitates towards the same implementation that has served me well over the years, and if you google "Value Objects in C#" you will find many many many articles describing the exact same approach. I can unfortunately not remember the origin of the approach that I tend to use, so I cannot give any credit here, but it seems that I'm not the only one (*that can be both good AND bad*).

The approach is based on having a base class that defines the equality logic, and then you create derivatives from that for your individual `Value Object` needs. Even though I'm not a huge advocate for inheritance as I subscribe to *"composition over inheritance"*, this is actually one of the few exceptions that I use myself. In return I get the communication aspect that I mentioned before, so to me this is an acceptable trade-off - in fact, I can tell new developers to go and find all derivatives of the `Value Object` base class to start building up an understanding of the domain, and to adapt/extend their domain vocabulary. Now that's useful!

### The ValueObject base class
Here is the C# implementation of the `Value Object` base class:
```csharp
public abstract class ValueObject
{
    protected abstract IEnumerable<object> GetEqualityComponents();

    public abstract override string ToString();

    public override bool Equals(object? obj)
    {
        if (obj is null)
        {
            return false;
        }

        if (GetType() != obj.GetType())
        {
            return false;
        }

        var valueObject = (ValueObject)obj;

        return GetEqualityComponents().SequenceEqual(valueObject.GetEqualityComponents());
    }

    public override int GetHashCode()
    {
        var hash = new HashCode();

        foreach (var component in GetEqualityComponents())
        {
            hash.Add(component);
        }

        return hash.ToHashCode();
    }

    public static bool operator ==(ValueObject? a, ValueObject? b)
    {
        if (ReferenceEquals(a, b))
        {
            return true;
        }

        if (a is null || b is null)
        {
            return false;
        }

        return a.Equals(b);
    }

    public static bool operator !=(ValueObject? a, ValueObject? b) => !(a == b);
}
```

As you can see it mostly contains the logic for comparing two instances, and choosing what to compare is handed over to derivatives that must implement the `GetEqualityComponents()` method and return the relevant information.

Alright, let's see it in action!

### Example: a ProductNumber implementation

Let's say that we have a domain where `Products` are a core concept, and the business refers to products by a **product number** like `P0312`, which also means that product numbers are core concepts of the domain as it's part of the language shared with the business. I would tend to represent this as a `Value Object` (for all the reasons mentioned above), and I'd write some parsing logic to ensure that the format of `Pxxxx` is respected throughout the application. Now, it doesn't sound like much and the following example is also not that complicated - but isn't that what we want?

```csharp
public class ProductNumber : ValueObject
{
    public static readonly ProductNumber None = new(Prefix + "00000");

    public const string Prefix = "P";
    private readonly string _value;

    private ProductNumber(string value)
    {
        _value = value;
    }

    public override string ToString() => _value;

    protected override IEnumerable<object> GetEqualityComponents()
    {
        yield return _value;
    }

    public static ProductNumber Parse(string? text)
    {
        if (TryParse(text, out var productNumber))
        {
            return productNumber;
        }

        throw new FormatException($"The value \"{text}\" is not a valid product number");
    }

    public static bool TryParse(string? text, out ProductNumber productNumber)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            productNumber = null!;
            return false;
        }

        if (!Regex.IsMatch(text, $@"^{Prefix}\d+$", RegexOptions.IgnoreCase))
        {
            productNumber = null!;
            return false;
        }

        productNumber = new ProductNumber(text.ToUpperInvariant());
        return true;
    }

    public static implicit operator ProductNumber(string value) => Parse(value);
    public static implicit operator string(ProductNumber productNumber) => productNumber._value;

    public static ProductNumber FromUnique(uint uniqueValue)
    {
        if (uniqueValue > 0)
        {
            return new ProductNumber(Prefix + uniqueValue.ToString("D5"));
        }
        
        throw new ArgumentOutOfRangeException(nameof(uniqueValue), uniqueValue, $"The value {uniqueValue} is not acceptable for product number");
    }
}
```

## Final thoughts
Now `Value Objects` seems like a small thing, but in my opinion they serve a big purpose as one of the building blocks when implementing principles and patterns from tacticle Domain-Driven Design. They serve a communication purpose between you and the next developer (might also be you in the future) that should set expectations about the purpose of the `Value Object` and why that piece of information is important, but it also extends beyond developers towards domain experts and should be part of the language that you use together to communicate; and to continuously discover the domain.

From a more technical perspective, by explicitly expressing **business primitives** as `Value Objects` you essentially extend the type system of your programming language (e.g. C# in this case) with those **business primitives**. So instead of having your usual `string`, `int`, `bool`, `datetime` etc., you now have `ProductNumber` that you can pass around in your source code. By doing this you also get a lot of help from your compiler, and you get fast feedback already at compile time because you now have a **business primitive** on the same level as your *programming language primitives*.

So in this blog post we looked at how to implement `Value Objects` in `C#`, but the concept can of course be used in any language. The approach of using a base class is just one of many different ways of going about it, and they all have certain traits to them that would make them attractive. I've tried to convey those of the more communicative nature that I tend to value, and I have enjoyed using this approach for a long time now.

*Thank you for reading this post.*