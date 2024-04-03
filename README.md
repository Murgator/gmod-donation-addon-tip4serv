## Donation addon for Garry's Mod (Tip4Serv)

This addon connects your [Tip4serv.com](https://tip4serv.com/?ads=github) store to your Garry's mod server. It checks if a player has made a donation on your Tip4Serv store and delivers the order in a minute (group, money...) by typing commands in the server console.

## HMAC authentication

Tip4serv adds a layer of security using HMAC authentication to communicate. It is a strong authentication method that is used by banks [HMAC WIKI](https://en.wikipedia.org/wiki/HMAC)

## Features for starter plan (only 5% fee)

- Unlimited game servers & commands
- Create subscriptions plan
- Commands status tracking
- Stock management
- Deliver roles & messages on Discord
- Create discount coupon
- Add managers for your store
- Purchase email and invoice
- Sales statistics
- Private flow for subscribers
- Custom sub-domain
- Resend commands
- Permanent commands
- No ads

## Features for PRO members (subscription required)

- Dynamic Dark/Light theme
- Account linking with avatars
- Product page with gallery & video
- GUI colors editor & additional CSS
- Top customers & related products

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

You can use ***{steam_id2}*** or ***{steam_id64}*** in your commands, they will be replaced by the player's Steam ID.

## Give commands & broadcast

***Give entity to a player:***

`tip4serv giveid {steam_id2} entity-name`

***Give ammo entity to a player:***

`tip4serv giveid {steam_id2} ammo-name quantity`

***Give armor to a player:***

`tip4serv givearmor {steam_id2} quantity`

***Send message to all players:***

`tip4serv say Thank you {gmod_username} for your {total_paid} {currency} donation`

[View all entities you can give](https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index30df.html)

## ULX commands

***Add a player to a group:***

`ulx adduserid {steam_id2} group-name`

***Remove a player from a group:***

`ulx removeuserid {steam_id2} group-name`

[View all ULX commands](https://ulyssesmod.net/ulx_docs/ulx-commands)

## DarkRP commands

***Give money to a player:***

`tip4serv addmoneyid {steam_id2} 100000`

***Change player job:***

`tip4serv jobid {steam_id2} job-name`

## SAM commands

***Add a player to a rank:***

`sam setrankid {steam_id2} VIP`

***Remove a player from a rank:***

`sam setrankid {steam_id2} user`

## sAdmin commands

***Add a player to a group:***

`sa Setrankid {steam_id2} group-name`

***Remove a player from a group:***

`sa Removeuser {steam_id2} group-name`

***Give ammo to a player:***

`sa Giveammo {steam_id2} ammo-name amount`

***Give entity to a player:***

`sa Give {steam_id2} entity-name`

## xAdmin commands

***Set a player group:***

`xadmin_setgroup {steam_id2} group-name`

## Permanent SWEPS/weapons

To provide players with permanent weapons, you have two options:

***Option 1: Use the [Permanent SWEPS addon](https://steamcommunity.com/sharedfiles/filedetails/?id=956066634)***

`perm_sweps_add {steam_id2} swep_class1`

***Option 2: Utilize the Tip4Serv addon's database feature***

Before proceeding, ensure that **MySQLOO** is installed on your Garry's Mod (Gmod) server.

1) Fill in the `mysql_` identifiers in the `garrysmod/data/tip4serv/config.json` file.
2) Enter `tip4serv connect` into your Gmod server console.
3) Edit your product in [MY PRODUCT](https://tip4serv.com/dashboard/my-products).
4) In the `Server commands` section, add your Gmod server, create a command, and select the option `Run each time the player spawns`.

## Quantity multiplier

You can also multiply the quantity choosen by the customer like this: `{quantity*50}`

Note: You must first activate the **Allow quantity choice** option in your product.

Use this command on Tip4serv if you want to sell bundles of $200 with darkrp plugin:

`tip4serv addmoneyid {steam_id2} {quantity*200}`

This will run in your server console after a purchase if the player buys product 4 times:

`tip4serv addmoneyid STEAM_0:1:35148628 800`

## Need help?

[Documentation](https://docs.tip4serv.com)

[Contact us](https://tip4serv.com/contact)
