<?php
/*
Copyright: 2014, Rod Roark <rod@sunsetsystems.com>

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

// For using the WordPress API from an external program such as this, see:
// http://www.webopius.com/content/139/using-the-wordpress-api-from-pages-outside-of-wordpress
// ... including the reader comments.
//
define('WP_USE_THEMES', false);
require('../../../wp-load.php');

// For use of the $wpdb object to access the WordPress database, see:
// http://codex.wordpress.org/Class_Reference/wpdb

$attachid = intval($_REQUEST['id']);
$userid = get_current_user_id();

// The ID of the currently logged-in user is relevant as a security measure.
$query =
  "SELECT a.* " .
  "FROM {$wpdb->prefix}cartpauj_pm_attachments AS a " .
  "JOIN {$wpdb->prefix}cartpauj_pm_messages AS m ON " .
  "m.id = a.message_id AND (m.from_user = %d OR m.to_user = %d) " .
  "WHERE a.id = %d";

$queryp = $wpdb->prepare($query, array($userid, $userid, $attachid));
if (empty($queryp)) die("Internal error: \"$query\" \"$userid\" \"$attachid\"");
$row = $wpdb->get_row($queryp, ARRAY_A);
if (empty($row)) die("No such attachment: $queryp");

$filename = $row['filename'];
$mimetype = $row['mimetype'];
$filesize = strlen($row['contents']);

header('Content-Description: File Transfer');
header('Content-Transfer-Encoding: binary');
header('Expires: 0');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Pragma: public');
header("Content-Disposition: attachment; filename=\"$filename\"");
header("Content-Type: $mimetype");
header("Content-Length: $filesize");

echo $row['contents'];

