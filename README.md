# finlay-s-fish
Finlay's Fish and Chips
Hello Fellow Developers!

Thank you for applying to work with us, we have read your CV and like it, the next step is a coding challenge. Please review and complete the coding question below. Don't worry, you have a week to finish. Things to know:

You must write your answer code in Java.
You may write and test your code outside of hacker rank and paste your final answer here for submission.
Your answer should be contained in a single source file (this is to make it easier for us to run tests on it) and you should write inner classes or package-private scoped classes where you might normally use separate source files.
We have provided a few sample tests for you to run your code against. Please keep in mind that we may run additional tests beyond what is included here.
You are welcome to look up information on the internet if you need to, however the answer should be your own.
This question isn't meant to be hard, but it is a chance for you to show us a little of your object-orientated-design ability. For example please avoid the temptation to solve the problem in a single while loop!
Once you have submitted a working answer, you've passed this round and we will arrange a time for a developer to call you for a phone interview. Expect us to talk about your answer, we'll ask you why you wrote the code the way you did and pick a few things in your code that we'd like to see you extend.
If you have any questions or feedback please feel free to contact your recruiter and we will be happy to help. We hope you find this question interesting and look forward to talking to you about it soon!

Finlay's Fish and Chips

Finlay owns a world renowned fish and chips shop selling the best fish and chips in London. The shop opens each day for lunch, customers queue up and Finlay sells food to customers who take it away to eat. In order to maintain world class food quality, Finlay wants to make sure the food is served quickly while it's hot, he would like you to design some software to help him organize his orders and his kitchen.

The Kitchen

The shop has a kitchen with two fryers:

a Fish Fryer which cooks both battered cod and battered haddock, it can cook up to four different fish at a time. Additional food can be added to the fish fryer while its cooking however there can never be more then four items in the fish fryer.
a Chip Fryer which cooks batches of chips. Each batch can be between one and four portions, once started the batch must finish cooking before the chip fryer can be used for the next.
The Food

Finlay serves three different items, each take a different amount of time to cook and must be cooked in a specific fryer:

Battered Cod - takes 80 seconds to cook in the fish fryer
Battered Haddock - takes 90 seconds to cook in the fish fryer
Chips - take 120 seconds to cook a batch of up to four portions in the chip fryer
The Orders

Finlay gets one order at a time, he puts each order into the software. The software will then work out which food should be added to which fryer and exactly when or it will report that its not possible to fulfill a good quality order.

orders must be cooked in sequence, each order will be served before the next is started
all food in an order must be served together
food must be prepared to order as Finlay does not want to waste any food and pre-cooking would ruin the flavour
when served, all food in an order must have been cooked within 120 seconds of it being served
an order must be completed within 600 seconds of it being entered
otherwise orders should be served as quickly as possible
If an order can't meet all of the above quality standards, then it must be rejected. Finlay is very fast, you can assume that once cooked it takes no time at all to get the food to the customer.

The Process

Finlay enters each customer order in the following format, he is very precise when entering orders and they are always well-formed.

Order #1, 12:00:00, 2 Cod, 4 Haddock, 3 Chips
Order #2, 12:00:30, 1 Haddock, 1 Chips
Order #3, 12:01:00, 21 Chips
After each order is entered the software returns a list of new cooking instructions and order states Finlay should use:

at 12:00:00, Order #1 Accepted
at 12:00:00, Begin Cooking 4 Haddock
at 12:00:50, Begin Cooking 3 Chips
at 12:01:30, Begin Cooking 2 Cod
at 12:02:50, Serve Order #1
at 12:00:30, Order #2 Accepted
at 12:02:50, Begin Cooking 1 Chips
at 12:03:20, Begin Cooking 1 Haddock
at 12:04:50, Serve Order #2
at 12:01:00, Order #3 Rejected
Challenge

Please write code to provide the cooking instructions and order states.
