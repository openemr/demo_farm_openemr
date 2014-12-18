<?php
/*
Plugin Name: Cartpauj PM
Plugin URI: https://wordpress.org/plugins/cartpauj-pm/
Description: Cartpauj PM allows you to add a simple Private Messaging system to your WordPress site. The messaging is done entirely through the front-end of your site rather than the Dashboard. This is very helpful if you want to keep your users out of the Dashboard area. Enjoy! :)
Version: 1.0.12
Author: Cartpauj, Sunset Systems
Author URI: http://www.sunsetsystems.com/
Text Domain: cartpaujpm
Copyright: 2009-2011 cartpauj; 2014 Rod Roark

GNU General Public License, Free Software Foundation <http://creativecommons.org/licenses/GPL/2.0/>
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

//INCLUDE THE CLASS FILE
include_once("pm-class.php");

//DECLARE AN INSTANCE OF THE CLASS
if(class_exists("cartpaujPM"))
	$cartpaujPMS = new cartpaujPM();

//HOOKS
if (isset($cartpaujPMS))
{
	//ACTIVATE PLUGIN
	register_activation_hook(__FILE__ , array(&$cartpaujPMS, "pmActivate"));

	//SETUP TEXT DOMAIN FOR TRANSLATIONS
	$plugin_dir = basename(dirname(__FILE__));
	load_plugin_textdomain('cartpaujpm', false, $plugin_dir.'/i18n/');

	//ADD SHORTCODES
	add_shortcode('cartpauj-pm', array(&$cartpaujPMS, "displayAll"));

	//ADD ACTIONS
	add_action('init', array(&$cartpaujPMS, "jsInit"));
	add_action('wp_head', array(&$cartpaujPMS, "addToWPHead"));
	add_action('admin_menu', array(&$cartpaujPMS, "addAdminPage"));
  // Required because register_activation_hook() is not called on plugin upgrade:
	add_action('plugins_loaded', array(&$cartpaujPMS, "pmActivate"));

	//ADD WIDGET
	register_sidebar_widget(__("Cartpauj-PM Widget", "cartpaujpm"), array(&$cartpaujPMS, "widget"));
}
?>
