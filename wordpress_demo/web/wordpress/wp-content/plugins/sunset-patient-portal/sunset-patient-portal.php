<?php
/*
Plugin Name: Sunset Patient Portal
Plugin URI: http://www.sunsetsystems.com/
Description: Patient interface to a medical clinic EHR system.
Version: 1.1
Author: Rod Roark
Author URI: http://www.sunsetsystems.com/
License: Not yet specified
*/

/*
Copyright 2014 Rod Roark (email: rod@sunsetsystems.com)
*/

if (!class_exists('Sunset_Patient_Portal')) {
  class Sunset_Patient_Portal {

    const CLASS_NAME = 'Sunset_Patient_Portal';

    public static function initialize() {

      // From http://codex.wordpress.org/Function_Reference/register_activation_hook:
      // The register_activation_hook function registers a plugin function to be run when the plugin
      // is activated.
      //
      // From PHP documentation of callable types: "Static class methods can also be passed without
      // instantiating an object of that class by passing the class name instead of an object at
      // index 0. As of PHP 5.2.3, it is also possible to pass 'ClassName::methodName'."
      //
      register_activation_hook  (__FILE__, array(self::CLASS_NAME, 'activate'  ));
      register_deactivation_hook(__FILE__, array(self::CLASS_NAME, 'deactivate'));

    } // END function initialize()

    //
    // Activate the plugin
    //
    public static function activate() {
      // Do nothing
    }

    //
    // Deactivate the plugin
    //		
    public static function deactivate() {
      // Do nothing
    }

  } // END class Sunset_Patient_Portal
} // END if (!class_exists('Sunset_Patient_Portal'))

Sunset_Patient_Portal::initialize();

