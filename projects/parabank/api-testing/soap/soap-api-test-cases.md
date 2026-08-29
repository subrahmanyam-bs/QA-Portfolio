# SOAP API Test Cases

**Service:** ParaBank SOAP Service
**Endpoint:** `https://parabank.parasoft.com/parabank/services/ParaBank`
**WSDL:** `https://parabank.parasoft.com/parabank/services/ParaBank?wsdl`, copy committed as [`parabank.wsdl`](parabank.wsdl)
**Namespace:** `http://service.parabank.parasoft.com/`
**Binding:** document/literal, SOAP 1.1, `soapAction=""`
**Executed:** 2026-08-28

---

## Finding the WSDL

The URL usually quoted for ParaBank's WSDL,
`https://parabank.parasoft.com/parabank/services/bank?wsdl`, returns **404**. The
service lives at `/parabank/services/ParaBank?wsdl`, which is what the Admin Page
links to. There's a second, unrelated service at
`/parabank/services/store-01?wsdl` (LoanProcessor), out of scope here.

## What's exposed

27 operations: `login`, `getAccount`, `getAccounts`, `getCustomer`,
`getTransaction`, `getTransactions`, `getTransactionsByAmount`,
`getTransactionsByMonthAndType`, `getTransactionsByToFromDate`,
`getTransactionsOnDate`, `transfer`, `deposit`, `withdraw`, `billPay`,
`createAccount`, `requestLoan`, `updateCustomer`, `buyPosition`, `sellPosition`,
`getPosition`, `getPositions`, `getPositionHistory`, `initializeDB`, `cleanDB`,
`setParameter`, `startupJmsListener`, `shutdownJmsListener`.

I picked two to test properly:

- **`login`**, the auth entry point, and the operation that shows what the service
  gives up about a customer
- **`getAccount`**, a representative read with a typed `xs:int` input, which lets
  me test how the schema handles bad input

## Tools

| Job | Tool |
|-----|------|
| Reading the WSDL, discovering operations, scaffolding requests | **SoapUI 5.7 Open Source**. File > New SOAP Project against the WSDL URL generates a skeleton per operation |
| Running the requests and capturing the exact evidence below | **curl 8.x**, so the bytes in this document are reproducible |
| Cross-checking against the REST equivalents | **Postman 11**, raw XML body plus the two headers |

Each case names the tool actually used.

## Two things that will trip you up

Child elements have to be namespace qualified. Send them bare and you get:
```
Unmarshalling Error: unexpected element (uri:"", local:"username")
```

`SOAPAction` has to be an empty string. Send `SOAPAction: "login"` and you get:
```
The given SOAPAction login does not match an operation.
```

Envelope template:

```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:ser="http://service.parabank.parasoft.com/">
  <soap:Body>
    <!-- operation here -->
  </soap:Body>
</soap:Envelope>
```

---

## 1. `login`

Schema: `login { username: xs:string, password: xs:string }` returns
`loginResponse { customerId: tns:customer }`

| TC ID | Scenario | Body | Expected | Tool | Priority | Status |
|-------|----------|------|----------|------|----------|--------|
| TC-S01 | Valid credentials | `<ser:login><ser:username>john</ser:username><ser:password>demo</ser:password></ser:login>` | 200, `loginResponse` for customer 12212 | curl, scaffolded in SoapUI | High | Pass |
| TC-S02 | Wrong password | `<ser:password>wrongpass</ser:password>` | Fault, "Invalid username and/or password" | curl | High | Pass |
| TC-S03 | `password` element missing | `<ser:login><ser:username>john</ser:username></ser:login>` | Schema validation fault naming the missing element | SoapUI | Medium | Partial pass - a fault comes back, but it's the business fault "Invalid username and/or password", not a validation fault |
| TC-S04 | Child elements unqualified | `<ser:login><username>john</username>...` | `soap:Client` fault explaining the namespace requirement | curl | Low | Pass |

TC-S01 response:
```xml
<ns2:loginResponse xmlns:ns2="http://service.parabank.parasoft.com/">
  <ns2:customerId>
    <id>12212</id>
    <firstName>John</firstName>
    <lastName>Smith</lastName>
    <address>
      <street>1431 Main St</street>
      <city>Beverly Hills</city>
      <state>CA</state>
      <zipCode>90210</zipCode>
    </address>
    <phoneNumber>310-447-4121</phoneNumber>
    <ssn>622-11-9999</ssn>
  </ns2:customerId>
</ns2:loginResponse>
```

Same as REST: the SSN comes back in the response, and the call needs no
WS-Security header, token or session. See [BUG-08](../../bug-reports/BUG-08.md).
Functionally it does what it should, so the row stays green.

TC-S02 fault:
```xml
<soap:Fault>
  <faultcode>soap:Server</faultcode>
  <faultstring>Invalid username and/or password</faultstring>
  <detail><ns1:ParaBankServiceException xmlns:ns1="http://service.parabank.parasoft.com/"/></detail>
</soap:Fault>
```
HTTP 500, which is correct for a SOAP 1.1 fault. Message is generic and doesn't
reveal whether the username exists. Good.

TC-S04 fault names the qualified names it wanted:
`Expected elements are <{http://service.parabank.parasoft.com/}username>,<{http://service.parabank.parasoft.com/}password>`.
Genuinely useful if you're writing a client.

## 2. `getAccount`

Schema: `getAccount { accountId: xs:int }` returns `getAccountResponse { account }`,
where account is `{ id, customerId, type, balance }`.

| TC ID | Scenario | Body | Expected | Tool | Priority | Status |
|-------|----------|------|----------|------|----------|--------|
| TC-S05 | Valid id | `<ser:accountId>13344</ser:accountId>` | 200, account matching REST and the UI | curl | High | Pass |
| TC-S06 | Id doesn't exist | `<ser:accountId>99999999</ser:accountId>` | Fault, "Could not find account #99999999" | curl | High | Pass |
| TC-S07 | Wrong data type | `<ser:accountId>abc</ser:accountId>` | `soap:Client` fault, rejected against `xs:int` | SoapUI | Medium | Pass |
| TC-S08 | `accountId` missing | `<ser:getAccount></ser:getAccount>` | Schema validation fault | SoapUI | Medium | Partial pass - defaults to 0 and returns the business fault "Could not find account #0" |

TC-S05 response:
```xml
<ns2:getAccountResponse xmlns:ns2="http://service.parabank.parasoft.com/">
  <ns2:account>
    <id>13344</id>
    <customerId>12212</customerId>
    <type>CHECKING</type>
    <balance>4222.93</balance>
  </ns2:account>
</ns2:getAccountResponse>
```
Matches `GET /services/bank/accounts/13344` and Accounts Overview exactly. See
[cross-validation](../../cross-validation/ui-api-integration-tests.md).

TC-S07 fault: `soap:Client`, `Unmarshalling Error: Not a number: abc`. Type
validation happens at the schema layer, which is a real advantage over REST, where
`GET /accounts/abc` gives you a bare 404 and an empty body.

---

## Results

| Result | Count |
|--------|-------|
| Pass | 8, two of them partial |
| Fail | 0 |
| **Total** | **8** |

## What I took away from this

**SOAP handles errors better than REST does here.** Every failure comes back as a
well-formed fault with a `faultcode` that correctly separates client errors from
server ones, plus a readable `faultstring`. Compare that to REST returning 400 for
not-found and bare 500s with empty bodies ([BUG-11](../../bug-reports/BUG-11.md)).

**Schema validation catches type errors** that REST lets through to an unhandled
exception. TC-S07 versus TC-R07 is the clearest example.

**Omitted elements aren't rejected**, TC-S03 and TC-S08. The service defaults
`xs:int` to 0 and a missing string to null, then fails with a business message
rather than a validation fault. That's a contract strictness gap, not a functional
defect, so I've logged it as an observation instead of a bug.

**No authentication, and login returns the SSN.** Identical to the REST findings.

**The three channels agree on data.** Account 13344 reported the same type and
balance through SOAP, REST and the Accounts Overview page.

**Bonus find.** SOAP was what surfaced the root cause of
[BUG-15](../../bug-reports/BUG-15.md). REST just returns an empty 500 on the
corrupted accounts, but `getAccount` returns
`<faultstring>Rounding necessary</faultstring>`, which points straight at a
`BigDecimal.setScale(2)` with no RoundingMode. Worth remembering when a REST
endpoint on this app goes opaque: try the SOAP equivalent, it talks more.

## Reproducing

**SoapUI**
1. File > New SOAP Project
2. Initial WSDL: `https://parabank.parasoft.com/parabank/services/ParaBank?wsdl`
3. Tick Create Requests, expand `login` or `getAccount`, open Request 1
4. Replace the `?` placeholders with values from the tables and submit

**curl**
```bash
curl -X POST "https://parabank.parasoft.com/parabank/services/ParaBank" \
  -H "Content-Type: text/xml;charset=UTF-8" \
  -H 'SOAPAction: ""' \
  --data-binary '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.parabank.parasoft.com/"><soap:Body><ser:getAccount><ser:accountId>13344</ser:accountId></ser:getAccount></soap:Body></soap:Envelope>'
```

**Postman**: POST to the endpoint, Body > raw > XML, paste the envelope, add the
two headers.

Note that 13344 is currently unreadable, see
[BUG-15](../../bug-reports/BUG-15.md). Use any of 14232, 14565, 14787, 15675,
15897, 16008 or 16119 instead until the database is reseeded.
