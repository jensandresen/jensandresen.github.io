---
title: "Tactical Domain-Driven Design - a how to guide"
date: 2020-04-26T19:02:21Z
draft: true
---

This is the first post in a series about how to implement the tactical elements of Domain-Drive Design. There will be examples written i `C#` but they can easily be translated to other languages.

## Background

I just want to tell about my motivation behind writing this series. I'm sure at this time that you are reading this, you will be able to find many other articles (and/or series) about the same topic - and I'm sure that they are all super great!

At the time of this writing I work as a contractor where I help clients adopt _modern_ software development practices. I usually work on systems that tempt to model one or more business processes and lala lalal lalla lal l.

Now, it's **very** important to adopt the language of the business in your code base. In our example here domain experts will describe the use case as

> "A member will be promoted to gold member..."

We will use this information - and the "language" - to write our code. In the above we are told that `Members` are `Promoted`.
