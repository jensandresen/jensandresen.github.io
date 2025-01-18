---
title: "Implementing DDD Series: Business Primitives with fixed value set as amplified enums"
description: This article explores how to model and implement business primitives as Value Objects in .NET and C#. It discusses their role in Domain-Driven Design, how they differ from entities, and their impact on both technical design and team communication.
summary: A look at Value Objects in Domain-Driven Design, including their implementation in C#, their purpose in extending the type system, and how they help protect business invariants while fostering a shared language between developers and domain experts.
published: 2025-01-13
draft: true
tags: ["DDD", "Domain-Driven Design", ".NET", "C#"]
categories: ["Development", "Design"]
images: ["/img/fixed-values-1.jpg"]
keywords: ["DDD", "Domain-Driven Design", "Value Objects", "Amplified Enums"]
---

![Building Blocks](/img/fixed-values-1.jpg)

*Phew, that title is a mouthful! Let's get into it.*

When we *continously* evolving our understanding of a domain and the concepts therein, it is common that we come across a business primitive that can only have a value that is defined within a fix set. 

Imagine working within a domain that handles credit card payments, and those payments can be made using different currencies. But the thing is - that payments are only accepted when using a few supported currencies and should be declined if the currency is not part of those.

- problem statement
- traditional enum
    - example of implementation
    - store in db
    - to string in api / domain events

## Amplified enum
...
- example: supported currency
- example: tracking status

## Final thoughts
...


*Thank you for reading this post.*