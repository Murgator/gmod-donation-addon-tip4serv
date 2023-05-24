## Donation addon for Garry's Mod (Tip4Serv)

This addon connects your [Tip4serv.com](https://tip4serv.com/?ads=github) store to your Garry's mod server. It checks if a player has made a donation on your Tip4Serv store and delivers the order in a minute (group, money...) by typing commands in the server console.

## HMAC authentication

Tip4serv adds a layer of security using HMAC authentication to communicate. It is a strong authentication method that is used by banks [HMAC WIKI](https://en.wikipedia.org/wiki/HMAC)

## Price

We take a 5% commission and that’s it ! You have access to all features with no subscription required.

## Features

* Unlimited game servers & commands
* Create subscriptions plan
* Commands status tracking
* Stock management
* Deliver roles & messages on Discord
* Easily offer a product to a friend
* Create discount coupon
* Add managers for your store
* Purchase email and invoice
* Sales statistics
* Private flow for subscribers
* Custom sub-domain
* Customize store colors
* No ads

## Store available in 15 languages

English, Danish, Dutch, English, French, German, Hungarian, Italian, Norwegian, Polish, Portuguese, Romanian, Russian, Spanish, Swedish and Turkish.

## Several payment methods

Here are the payment methods you can offer your players: Card, Paypal, Google Pay, Ideal, Giropay, Bancontact, Sofort, Sepa, EPS, BACS, Multibanco, BECS, Przelexy24, BOLETO, OXXO, Afterpay.

## Installation

Open an account on [Tip4serv.com](https://tip4serv.com/?ads=github), follow the instructions and add a Gmod server.

1) Drag and drop `tip4serv` folder into `garrysmod/addons` directory on your Gmod server.
2) Restart your server and set `key` to your tip4serv API key in `garrysmod/data/tip4serv/config.json`.
3) Type `tip4serv connect` in your Gmod server console.

> You should get this message: **Server has been successfully connected**

## Setting up commands on Tip4Serv

***Before setting up your commands on Tip4serv.com, you should know the commands you configure will be executed in your server's console (not ingame as an admin).***

***Make sure that there is at least 1 player connected on your server when you test a purchase on tip4serv, otherwise commands will not be processed.***

Here are some commands example you can use in the products configuration: [MY PRODUCTS](https://tip4serv.com/dashboard/my-products).

You can use all the console commands of the addons that you have installed on your server.


***Add a player to a group (ULX):***

`ulx adduser {gmod_username} group-name`

or

`ulx adduserid {steam_id} group-name`

***Remove a player from a group (ULX):***

`ulx removeuser {gmod_username} group-name`

or

`ulx removeuserid {steam_id} group-name`

***Give money to a player (DarkRP):***

`darkrp addmoney {gmod_username} amount`

[View all ULX commands](https://ulyssesmod.net/ulx_docs/ulx-commands)

## Custom ULX addon

Required: [Custom ULX addon](https://steamcommunity.com/sharedfiles/filedetails/?id=718665054)

***Example to give Alyx's gun to a player:***

`ulx give {gmod_username} weapon_alyxgun`

[View all entities](https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index30df.html)

## Need help?

[Documentation](https://docs.tip4serv.com)

[Contact us](https://tip4serv.com/contact)
