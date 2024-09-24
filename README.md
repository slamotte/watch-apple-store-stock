# Watch Apple Store Stock

## Purpose

Notifies you when an item is available for pickup at your favourite Apple Store.

## Description

After reading a parameter file containing a list of products to check for, this utility fetches product availability for the given store from the Apple website.
If a product is found, a message is written to the console.
If SMS configuration is present, an SMS message is also sent out.
That product is then removed from the list of products so we don't send out the same alert twice (unless the script is restarted).

## Requirements

* Ruby 3.3.4
* rubygems
* bundler
* experience working with your browser's developer tools<sup>2</sup>, otherwise this utility probably isn't for you.

## Setup

Copy the `params.sample.yml` file to `params.yml` and update the following entries. All values are required unless otherwise noted.
* `sms`: config for sending SMS notifications<sup>1</sup> (optional)
  * `api_username`: your voip.ms login/email address
  * `api_password`: your voip.ms API password (NOT your account password)
  * `source`: voip.ms phone number to send messages from
  * `destinations`: list of phone numbers to send notifcations
* `store`
  * `id`: the unique id<sup>2</sup> of the store
  * `name`: a descriptive name for the store
  * `url`: the `pickup-message` endpoint for your country's website, query parameters excepted.
  Ensure this is correct for your country<sup>3</sup>.
  For example, if you try to watch American products on the Canadian website, an error will occur.
* `products`: a list of product info. Each product has the following attributes:
  * `id`: the unique id<sup>2</sup> of the product
  * `option`: the option of the product. Can be used for combos e.g. watch + strap (optional)
  * `name`: a descriptive name for the product
  * `storage`: a value for the product's storage (optional)
  * `color`: a value for the product's color (optional)

Run ` bundle install` to install the required gems.
Launch the utility using `./monitor`

_<sup>1</sup> You need an account at https://voip.ms in order to send out notifications.
It would be straightforward to implement other SMS providers, but this is all I need._

_<sup>2</sup> Ids can be found by viewing the product pages on Apple's website and examining the URL for the `pickup-message` requests in your browser's developer tools, specifically the network requests.
As an example, consider https://www.apple.com/ca/shop/retail/pickup-message?parts.0=MHXH3AM%2FA&searchNearby=true&store=R369.
Here the product id is `MHXH3AM/A` (escaped "/") and the store id is `R369`._

_<sup>3</sup> Try the following format:
`https://www.apple.com/<country_code>/shop/retail/pickup-message`
where `<country_code>` is your country's code e.g. `ca` for Canada.
Leave this missing for the USA._
