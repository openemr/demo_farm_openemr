=== Cartpauj PM ===
Contributors: cartpauj, sunsetsystems
Tags: private, message, messaging, messages, user message, user messages, user messaging, private message, private messages, private messaging, mail, email, local, users, chat, discussion, post, thread
Requires at least: 2.7
Tested up to: 3.9.1
Stable tag: 1.0.11
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

Easily add Private Messaging for your users to your WordPress site with Cartpauj PM (Private Messages).

== Description ==
Cartpauj PM (Private Messages) allows you to easily add a Private Messaging system to your Wordpress blog/site. Unlike other Private Messaging plugins available, Cartpauj PM works through a Page rather than the WP Dashboard -- This is very helpful if you want to keep users out of the Dashboard area! Please see the features and wish lists below for more about what Cartpauj PM currently does and what's been requested for the future.

= Important Note for Upgraders =
If you are upgrading an existing Cartpaug PM install to version 1.0.11, you will need to deactivate and then re-activate the plugin in order for the required new table to be created. This will be fixed in the next release.

= Features =
* Works through a Page rather than the dashboard. This is very helpful if you want to keep your users out of the Dashboard area!
* Users can privately message one another.
* Option to restrict message sending to only an admin user; in this case only the designated admin user may message any other user.
* Threaded messages.
* BBCode in messages.
* Messages may have attachments. Attachments are stored in the database for security.
* Ability to embed things into messages like YouTube, Photobucket, Flickr, Wordpress TV, more.
* Admins can send a public announcement for all users to see.
* Admins can set the max amount of messages a user can keep in his/her box. This is helpful for keeping Database sizes down.
* Admins can set how many messages to show per page in the message box.
* Users can select whether or not they want to recieve messages.
* Users can select whether or not they want to be notified by email when they recieve a new message.

= Wish List =
* Add "email all users" option when admins create an announcement.
* Allow multiple messages to be deleted at once.
* Admin setting to edit time display.
* Paging in threaded messages (maybe).
* Option to use Drop-Down menu or Ajax Autocomplete in the "To:" field when creating a new message.
* Option to delete a single reply in message thread view (maybe).
* Probably more stuff eventually too...

= Note =
Cartpauj PM includes its own stylesheet to try and make it work with as many themes as possible. However some CSS adjustments may be required for you to make it look just right on your site.

= Translations =
* Bulgarian (bg_BG)
* Czech (cs_CS)
* Danish (da_DK)
* French (fr_FR)
* German (de_DE)
* Italian (it_IT)
* Polish (pl_PL)
* Russian (ru_RU)
* Spanish (es_ES)
* Turkish (tr_TR)
* Simplified Chinese (za_CN)
* Slovak (sk_SK)
* Slovanian (sl_SI)
* Chinese Taiwan (za_TW)

== Installation ==
1. Upload 'cartpauj-pm.zip' to the '/wp-content/plugins/' directory

2. Activate the plugin through the 'Plugins' menu in WordPress, you will see a new page under the "Settings" portion of your dashboard.

3. Create a page for "Messages" and copy [cartpauj-pm] into it and publish.

4. Configure Cartpauj PM the way you wish.

== Frequently Asked Questions ==
n/a

== Upgrade Notice ==
n/a

== Changelog ==
= 1.0.11 =
* New maintainer "sunsetsystems".
* Added optional support for a messaging administrator who is the only person allowed to message other users.
* Added support for attachments.
* Fixed bug with "checked='checked'" appearing at the top of the admin settings page.
= 1.0.10 =
* WP 3.5 compatibility fixes
* Fixed pagination issue when permalinks not set to default
* Fixed auto-suggest issue
* Added option to disable "Cartpauj PM" branding in footer
* Added warning before deleting a message
* Added a directory listing page
* Made some CSS adjustments
* Corrected a few spelling errors (Thanks to Flick)
* Updated Template.pot file for translators
* Updated Italian Translation (Big thanks to Giuseppe)
* Added Simplified Chinese Translation (Big thanks to Yan Wei)
* Added French Translation (Big thanks to Kalawette)
* Added Slovak Translation (Big thanks to Vladimir)
* Added Chinese (Taiwan) Translation (Big thanks to Flick)
* Added Polish Translation (Big thanks to errorsys)
* Added Slovenian Translation (Big thanks to Tadej)
* Added Russian Translation (Big thanks to jabboroff)
= 1.0.09 =
* Added the ability for other plugins to interface with Cartpauj PM
= 1.0.08 =
* Fixed bugs preventing users with PHP 4 from using the plugin
* Added Bulgarian Translation (Big thanks to [DD Art](http://ddart-bg.com/))
* Added Danish Translation (Big thanks to [GeorgWP](http://wordpress.blogos.dk))
= 1.0.07 =
* Fixed bug in BBCode still showing [embed] [/embed] tags
= 1.0.06 =
* Added ability to embed things into messages like YouTube, Photobucket, Flickr, Wordpress TV, more
* Added Turkish Translation (Big thanks to [Selim Eski](http://selimeski.info/))
* Added Spanish Translation (Big thanks to [Diana](http://www.ejecutivadelhogar.com/))
= 1.0.05 =
* Fixed a security bug that allowed users to view messages that did not belong to them
* Modified the code to be more backwards-compatible with PHP 4
* Updated Italian Translation (Big thanks to [Giuseppe](http://www.iononmollo.it/))
* Updated Czech Translation (Big thanks to [adiumac](http://cad.hieke.at/))
* Updated German Translation (Big thanks to [adiumac](http://cad.hieke.at/) and [coax](http://www.coaxials.net "coax"))
= 1.0.04 =
* Added a count to the widget and header area for announcements
* Added Italian Translation (Big thanks to [Giuseppe](http://www.iononmollo.it/))
* Added Czech Translation (Big thanks to [adiumac](http://cad.hieke.at/))
* Updated German Translation (Big thanks to [adiumac](http://cad.hieke.at/) and [coax](http://www.coaxials.net "coax"))
= 1.0.03 =
* Fixed some sytactical bugs (thanks to coax and adiumac)
* Added a basic public announcements feature for admins to message all members at once (more will be coming on this, see todo list below)
* Added a "To:" field when viewing the message box, so you can see who the message was sent to (Thanks to [Gene53](http://eccentricnexus.com/) for making me do it ;))
= 1.0.02 =
* Fixed a bug when the plugin is translated into other languages
* Added German Translation (Big thanks to [adiumac](http://cad.hieke.at/) and [coax](http://www.coaxials.net "coax"))
* Added a TODO list to the Readme.txt file so users will know what's planned for future releases
= 1.0.01 =
* First official release

== Screenshots ==
n/a
