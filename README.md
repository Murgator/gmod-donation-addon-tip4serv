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

English, Danish, Dutch, French, German, Hungarian, Italian, Norwegian, Polish, Portuguese, Romanian, Russian, Spanish, Swedish and Turkish.

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

## Steam ID format

You can use {steam_id2} or {steam_id64}

{steam_id} is the same as {steam_id2}

## Give commands & broadcast

***Give entity to a player:***

`tip4serv giveid {steam_id} entity-name`

***Give ammo entity to a player:***

`tip4serv giveid {steam_id} ammo-name quantity`

***Send message to all players:***

`tip4serv say Thank you {gmod_username} for your {total_paid} {currency} donation`

[View all entities you can give](https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index30df.html)

## ULX commands

***Add a player to a group:***

`ulx adduserid {steam_id} group-name`

***Remove a player from a group:***

`ulx removeuserid {steam_id} group-name`

[View all ULX commands](https://ulyssesmod.net/ulx_docs/ulx-commands)

## DarkRP commands

***Give money to a player:***

`tip4serv addmoneyid {steam_id} amount`

***Change player job:***

`tip4serv jobid {steam_id} job-name`

## SAM commands

***Add a player to a rank:***

`sam setrankid {steam_id} VIP`

***Remove a player from a rank:***

`sam setrankid {steam_id} user`

## sAdmin commands

***Add a player to a group:***

`sa Setrankid {steam_id} group-name`

***Remove a player from a group:***

`sa Removeuser {steam_id} group-name`

***Give ammo to a player:***

`sa Giveammo {steam_id} ammo-name amount`

***Give entity to a player:***

`sa Give {steam_id} entity-name`

## xAdmin commands

***Set a player group:***

`xadmin_setgroup {steam_id} group-name`

## Quantity multiplier

You can also multiply the quantity choosen by the customer like this: `{quantity*50}`

Note: You must first activate the **Allow quantity choice** option in your product.

Use this command on Tip4serv if you want to sell bundles of $200 with darkrp plugin:

`tip4serv addmoneyid {steam_id} {quantity*200}`

This will run in your server console after a purchase if the player buys product 4 times:

`tip4serv addmoneyid STEAM_0:1:35148628 800`

## Need help?

[Documentation](https://docs.tip4serv.com)

[Contact us](https://tip4serv.com/contact)
