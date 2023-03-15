# Creating an integration using the module
In this article, we will go in to detail about how to create a payment service
provider integration for the NP Retail payment gateway module.

Since we don't have an example payment service provider to integrate to, 
this example app just writes to a log entry table, but in the real world you 
would probably call an API using HTTP or similar.

## Prerequisite
To integrate with the module using this example integration, you will need NP
Retail release version 19.0 or greater. If you have a BC 2022 RW2 (BC22) isntance
that would correspond to version `21.19.0.10000` or greater.

**NOTE**: NaviPartner always recommends using the latest AppSource release available for your tenant!

## Overview
NaviPartner's payment gateway module offers three different operations, usually
supported by all payment service providers:

- Capturing a transaction
- Refunding a transaction
- Cancelling a transaction

To allow this, each integration has to, at least to some extent, implement all
three actions. This is done by implementing the `NPR IPayment Gateway`
interface. The interface defines the following four procedures:

```al
procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
procedure RunSetupCard(PaymentGatewayCode: Code[10])
```

The procedures will be explained in detail in the following sections. To create
the integration you need to create a codeunit that implements the interface,
along with a value for the `NPR PG Integrations` enum that references your
implementation of the interface.

## Setup & secret management
Most payment service providers require you to provide some information about who
you are, what you want access to or similar. This could be represented by an API
key, merchant name or similar.

To achieve this each integration should provide its own setup table that has a
primary key matching to the primary key that is used in the general setup table
for all integrations, a `Code[10]` field.

When the user clicks the **Show Setup Card** action in the UI, NP Retail will
trigger the `RunSetupCard(PaymentGatewayCode: Code[10])` procedure. It is
expected that the integration itself opens the correct card page with the
corresponding record. This is done in the example app in this way:

https://github.com/navipartner/payment-gateway-integration-example/blob/f7ce8b5a50c724937cef2f7e3b8bbf7365cbf4af/App/PSP%20Integration/PSPIntegration.Codeunit.al#LL82-L98C9

As part of the `Request` record variable sent in the payment operation procedures, the integration will be able to know what setup table to get and use data from.

## Performing payment operations
<!-- Filling out request and response -->
For all payment operations (`Capture`, `Refund`, and `Cancel`) the integration will be provided a `Request` record variable of type `NPR PG Payment Request` and a `Response` 
record variable of type `NPR PG Payment Response`. Both of these tables are temporary, and will have no records inserted in them, so the integration code should _only_ interact 
with the values provided.

### The `Request` object
The `Request` parameter contains multiple fields that the integration can use to
determine what operation it should do. Most notably is the `Transaction ID`, '
`Request Amount`,  and `Payment Gateway Code`. These three combined with the procedure 
context that the integration is should make it possible to perform any given operation.

Additional information is provided in the `Last Operation Id`, `Document Table No.`, 
`Document System Id` fields.

**NOTE**: The `Document System Id` field might be a null-guid if the operation is a
cancel operation as the payment gateway module cannot find the ID.

If the payment service provider requires an object, or the integration wants to log
information about the action that it performed towards the payment service provider,
then this can be logged using the `Request.AddBody(...)` procedures. The information
will be saved in the log entry together with other information about the `Request`
object.

### The `Response` object
The `Response` object should be filled out by the integration with information
relating to how the operation with the payment service provider went.

It is mandatory for the integration to ensure the value of the `Response Success`
field is correct, and represents if the operation was correctly performed.
It is also required for the integration to enter the response body from the
payment service provider using the `Response.AddResponse(...)` procedures.

If the integration got an operation Id from the payment service provider, it is
recommended to save that value in the `Response Operation Id` field. If the
integration for example requires the Id of the capture operation for the refund
operation, then it should be added to the field, and the payment gateway module
will provide it in the `Last Operation Id` field on the `Request` record for the
next operation.

### What if my Payment Service Provider does not support a given operation?
Due to the nature of the interface, you will have to implement all the procedures.
It is our recommendation that you simply do an `Error()`in the procedure(s) that
the payment service provider does not support.

Remember to give it a descriptive error message, as this will be shown to the user.

## Error handling
A large part of developing a good integration is dealing with errors in a
well-defined way.

### `CommitBehavior`
All executions of payment operations are run in a
[`CommitBehavior(CommitBehavior::Error)`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/attributes/devenv-commitbehavior-attribute)
context. This means that the integration itself _cannot_ commit data written
during the procedure. The module will however commit the data once the execution
of your code is done. 

### Errors thrown during execution
Any errors throw during execution of the integration code will be caught and logged 
by the payment gateway module. Throwing an error will also show the user a message 
dialogue with the corresponding error message.

The payment gateway module does not use errors to determine whether or not the
operation was a success. To determine this it solely uses the
`Response."Response Success"` field. This is done to ensure that it is possible
for the integration to throw an error if it cannot parse the response (for
example if you want to save the request id given by the API), but still mark the
operation as completed successfully.
It is therefore **crucial** that the integration fills out this property
accordingly.
