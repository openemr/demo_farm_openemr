<?php
// Copyright 2014 Rod Roark
//
// For using the WordPress API from an external program such as this, see:
// http://www.webopius.com/content/139/using-the-wordpress-api-from-pages-outside-of-wordpress
// ... including the reader comments.
//
define('WP_USE_THEMES', false);
require('../../../wp-load.php');

// Specify the forms plug-in used.  Currently only NINJA is supported.
define('FORMS_METHOD', 'NINJA');

// For use of the $wpdb object to access the WordPress database, see:
// http://codex.wordpress.org/Class_Reference/wpdb

$out = array('errmsg' => '');
$action = $_REQUEST['action'];

// These are the administrative settings for the Cartpauj PM plugin.
// We need to know who its messaging administrator is. This is likely to
// be the same as $_REQUEST['login'] but we cannot assume that.
$adminOps = get_option('cartpaujPM_options');
$admin_user_login = $adminOps['admin_user_login'];

// While the password is sent to us as plain text, this transport interface
// should always be encrypted via SSL (HTTPS). See also:
// http://codex.wordpress.org/Function_Reference/wp_authenticate
// http://codex.wordpress.org/Class_Reference/WP_User
$user = wp_authenticate($_REQUEST['login'], $_REQUEST['password']);

if (is_wp_error($user)) {
  $out['errmsg'] = "Portal authentication failed.";
}
// Portal administrator must have one of these capabilities.
// Note manage_portal is a custom capability added via User Role Editor.
else if (!$user->has_cap('create_users') && !$user->has_cap('manage_portal')) {
  $out['errmsg'] = "This login does not have permission to administer the portal.";
}
else {
  if ('list'        == $action) action_list       ($_REQUEST['date_from'], $_REQUEST['date_to']); else
  if ('getpost'     == $action) action_getpost    ($_REQUEST['postid']                         ); else
  if ('getupload'   == $action) action_getupload  ($_REQUEST['uploadid']                       ); else
  if ('delpost'     == $action) action_delpost    ($_REQUEST['postid']                         ); else
  if ('checkptform' == $action) action_checkptform($_REQUEST['patient'], $_REQUEST['form']     ); else
  if ('getmessage'  == $action) action_getmessage ($_REQUEST['messageid']                      ); else
  if ('getmsgup'    == $action) action_getmsgup   ($_REQUEST['uploadid']                       ); else
  if ('delmessage'  == $action) action_delmessage ($_REQUEST['messageid']                      ); else
  if ('adduser'     == $action) action_adduser($_REQUEST['newlogin'], $_REQUEST['newpass'], $_REQUEST['newemail']); else
  if ('putmessage'  == $action) action_putmessage ($_REQUEST                                   ); else
  // More TBD.
  $out['errmsg'] = 'Action not recognized!';
}

// For JSON-over-HTTP we would echo json_encode($out) instead of the following.
// However serialize() works better because it supports arbitrary binary data,
// thus attachments do not have to be base64-encoded.

$tmp = serialize($out);
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename=cmsreply.bin');
header('Content-Transfer-Encoding: binary');
header('Expires: 0');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Pragma: public');
header('Content-Length: ' . strlen($tmp));
ob_clean();
flush();
echo $tmp;

function get_mime_type($filepath) {
  if (function_exists('finfo_open')) {
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimetype = finfo_file($finfo, $filepath);
    finfo_close($finfo);
  }
  else {
    $mimetype = mime_content_type($filepath);
  }
  if (empty($mimetype)) $mimetype = 'application/octet-stream';
  return $mimetype;
}

function convertToID($login) {
  global $wpdb;
  $result = $wpdb->get_var($wpdb->prepare("SELECT ID FROM {$wpdb->users} WHERE user_login = %s", $login));
  if (!empty($result)) return $result;
  return 0;
}

// Logic to process the "list" action.
// For Ninja, a row for every form submission.
//
function action_list($date_from='', $date_to='') {
  global $wpdb, $out, $admin_user_login;
  $out['list'] = array();
  $out['messages'] = array();
  if (FORMS_METHOD == 'NINJA') {
    // Get list of requests.
    $query =
      "SELECT fs.id, fs.date_updated, u.user_login, f.data AS formdata " .
      "FROM {$wpdb->prefix}ninja_forms_subs AS fs " .
      "JOIN {$wpdb->prefix}ninja_forms AS f ON f.id = fs.form_id " .
      "LEFT JOIN $wpdb->users AS u ON u.ID = fs.user_id " .
      "WHERE 1 = %d";
    $qparms = array(1);
    if ($date_from) {
      $query .= " AND fs.date_updated >= %s";
      $qparms[] = "$date_from 00:00:00";
    }
    if ($date_to) {
      $query .= " AND fs.date_updated <= %s";
      $qparms[] = "$date_to 23:59:59";
    }
    $query .= " ORDER BY fs.date_updated";
    $query = $wpdb->prepare($query, $qparms);
    if (empty($query)) {
      $out['errmsg'] = "Internal error: wpdb prepare() failed.";
      return;
    }
    $rows = $wpdb->get_results($query, ARRAY_A);
    foreach ($rows as $row) {
      $formtype = '';
      $formdata = unserialize($row['formdata']);
      if (isset($formdata['form_title'])) $formtype = $formdata['form_title'];
      $out['list'][] = array(
        'postid'   => $row['id'],
        'user'     => (isset($row['user_login']) ? $row['user_login'] : ''),
        'datetime' => $row['date_updated'],
        'type'     => $formtype,
      );
    }
    // Get list of messages also.
    $query = "SELECT cm.id, cm.date, cm.message_title, " .
      "uf.user_login AS from_login, ut.user_login AS to_login " .
      "FROM {$wpdb->prefix}cartpauj_pm_messages AS cm " .
      "LEFT JOIN $wpdb->users AS uf ON uf.ID = cm.from_user " .
      "LEFT JOIN $wpdb->users AS ut ON ut.ID = cm.to_user " .
      "WHERE (cm.from_del = 0 AND uf.user_login = %s OR " .
      "cm.to_del = 0 AND ut.user_login = %s)";
    $qparms = array($admin_user_login, $admin_user_login);
    if ($date_from) {
      $query .= " AND cm.date >= %s";
      $qparms[] = "$date_from 00:00:00";
    }
    if ($date_to) {
      $query .= " AND cm.date <= %s";
      $qparms[] = "$date_to 23:59:59";
    }
    $query .= " ORDER BY cm.date";
    $query = $wpdb->prepare($query, $qparms);
    if (empty($query)) {
      $out['errmsg'] = "Internal error: wpdb prepare() failed.";
      return;
    }
    $rows = $wpdb->get_results($query, ARRAY_A);
    foreach ($rows as $row) {
      $out['messages'][] = array(
        'messageid' => $row['id'],
        'user'      => ($row['from_login'] == $admin_user_login ? $row['to_login'] : $row['from_login']),
        'fromuser'  => $row['from_login'],
        'touser'    => $row['to_login'],
        'datetime'  => $row['date'],
        'title'     => $row['message_title'],
      );
    }
  }
}

// Logic to process the "getpost" action.
// The $postid argument identifies the form instance.
// For Ninja the submitted field values and names must be extracted from
// serialized globs, and each field name comes from its description text.
//
function action_getpost($postid) {
  global $wpdb, $out;
  $out['post'] = array();
  $out['uploads'] = array();
  if (FORMS_METHOD == 'NINJA') {
    // wp_ninja_forms_subs has one row for each submitted form.
    // wp_ninja_forms has one row for each defined form.
    $query =
      "SELECT fs.id, fs.form_id, fs.date_updated, u.user_login, " .
      "f.data AS formdata, fs.data AS seldata " .
      "FROM {$wpdb->prefix}ninja_forms_subs AS fs " .
      "JOIN {$wpdb->prefix}ninja_forms AS f ON f.id = fs.form_id " .
      "LEFT JOIN $wpdb->users AS u ON u.ID = fs.user_id " .
      "WHERE fs.id = %d";
    $queryp = $wpdb->prepare($query, array($postid));
    if (empty($queryp)) {
      $out['errmsg'] = "Internal error: \"$query\" \"$postid\"";
      return;
    }
    $row = $wpdb->get_row($queryp, ARRAY_A);
    if (empty($row)) {
      $out['errmsg'] = "No rows matching: \"$postid\"";
      return;
    }
    $formid = $row['form_id'];
    $formtype = '';
    $formdata = unserialize($row['formdata']);
    if (isset($formdata['form_title'])) $formtype = $formdata['form_title'];
    $out['post'] = array(
      'postid'   => $row['id'],
      'user'     => (isset($row['user_login']) ? $row['user_login'] : ''),
      'datetime' => $row['date_updated'],
      'type'     => $formtype,
    );
    $out['fields'] = array();
    $out['labels'] = array();
    $seldata = unserialize($row['seldata']);
    // For each field in the form...
    foreach ($seldata as $selval) {
      $fieldid = $selval['field_id'];
      // wp_ninja_forms_fields has one row for each defined form field.
      $query2 =
        "SELECT data FROM {$wpdb->prefix}ninja_forms_fields " .
        "WHERE form_id = %d AND id = %d";
      $query2p = $wpdb->prepare($query2, array($formid, $fieldid));
      if (empty($query2p)) {
        $out['errmsg'] = "Internal error: \"$query2\" \"$postid\" \"$fieldid\"";
        continue;
      }
      // echo "$query2p\n"; // debugging
      $fldrow = $wpdb->get_row($query2p, ARRAY_A);
      if (empty($fldrow)) continue; // should not happen
      $flddata = unserialize($fldrow['data']);
      // Report uploads, if any.
      if (isset($flddata['upload_location']) && is_array($selval['user_value'])) {
        foreach ($selval['user_value'] as $uparr) {
          if (empty($uparr['upload_id'])) continue;
          $filepath = $uparr['file_path'] . $uparr['file_name'];
          // Put the info into the uploads array.
          $out['uploads'][] = array(
            'filename' => $uparr['user_file_name'],
            'mimetype' => get_mime_type($filepath),
            'id'       => $uparr['upload_id'],
          );
        }
      }
      // Each field that matches with a field name in OpenEMR must have that name in
      // its description text. Normally this is in the form of an HTML comment at the
      // beginning of this text, e.g. "<!-- field_name -->".  The regular expression
      // below picks out the name as the first "word" of the description.
      if (!preg_match('/([a-zA-Z0-9_:]+)/', $flddata['desc_text'], $matches)) continue;
      $fldname = $matches[1];
      if (is_string($selval['user_value'])) {
        // Ninja stupidly stores values encoded for HTML output.
        $out['fields'][$fldname] = htmlspecialchars_decode($selval['user_value'], ENT_QUOTES | ENT_HTML401);
      }
      else {
        $out['fields'][$fldname] = $selval['user_value'];
      }
      $out['labels'][$fldname] = $flddata['label'];
    }
  }
}

// Logic to process the "delpost" action to delete a post.
//
function action_delpost($postid) {
  global $wpdb, $out;
  if (FORMS_METHOD == 'NINJA') {
    // If this form instance includes any file uploads, then delete the
    // uploaded files as well as the rows in wp_ninja_forms_uploads.
    action_getpost($postid);
    if ($out['errmsg']) return;
    foreach ($out['uploads'] as $upload) {
      $query = "SELECT fu.data " .
        "FROM {$wpdb->prefix}ninja_forms_uploads AS fu WHERE fu.id = %d";
      $drow = $wpdb->get_row($wpdb->prepare($query,
      array('id' => $upload['id'])), ARRAY_A);
      $data = unserialize($drow['data']);
      $filepath = $data['file_path'] . $data['file_name'];
      @unlink($filepath);
      $wpdb->delete("{$wpdb->prefix}ninja_forms_uploads",
        array('id' => $upload['id']), array('%d'));
    }
    $out = array('errmsg' => '');
    // Finally, delete the form instance.
    $tmp = $wpdb->delete("{$wpdb->prefix}ninja_forms_subs", array('id' => $postid), array('%d'));
    if (empty($tmp)) {
      $out['errmsg'] = "Delete failed for id '$postid'";
    }
  }
}

// Logic to process the "adduser" action to create a user as a patient.
//
function action_adduser($login, $pass, $email) {
  global $wpdb, $out, $user;
  // if (!$user->has_cap('create_users')) {
  //   $out['errmsg'] = "Portal administrator does not have permission to create users.";
  //   return;
  // }
  if (empty($login)) $login = $email;
  $userid = wp_insert_user(array(
    'user_login' => $login,
    'user_pass'  => $pass,
    'user_email' => $email,
    'role'       => 'patient',
  ));
  if (is_wp_error($userid)) {
    $out['errmsg'] = "Failed to add user '$login': " . $userid->get_error_message();
  }
  else {
    $out['userid'] = $userid;
  }
}

// Logic to process the "checkptform" action to determine if a form is pending for
// the given patient login and form name.  If it is its request ID is returned.
//
function action_checkptform($patient, $form) {
  global $wpdb, $out;
  $out['list'] = array();

  if (FORMS_METHOD == 'NINJA') {
    // MySQL pattern for matching the form name in wp_ninja_forms.data.
    $pattern = '%s:10:"form_title";s:' . strlen($form) . ':"' . $form . '";%';
    $query =
      "SELECT fs.id FROM " .
      "$wpdb->users AS u, " .
      "{$wpdb->prefix}ninja_forms_subs AS fs, " .
      "{$wpdb->prefix}ninja_forms AS f " .
      "WHERE u.user_login = %s AND " .
      "fs.user_id = u.id AND " .
      "f.id = fs.form_id AND " .
      "f.data LIKE %s " .
      "ORDER BY fs.id LIMIT 1";
    $queryp = $wpdb->prepare($query, array($patient, $pattern));
    if (empty($queryp)) {
      $out['errmsg'] = "Internal error: \"$query\" \"$patient\" \"$pattern\"";
      return;
    }
    $row = $wpdb->get_row($queryp, ARRAY_A);
    $out['postid'] = empty($row['id']) ? '0' : $row['id'];
  }
}

// Logic to process the "getupload" action.
// Returns filename, mimetype, datetime and contents for the specified upload ID.
//
function action_getupload($uploadid) {
  global $wpdb, $out;
  if (FORMS_METHOD == 'NINJA') {
    $query = "SELECT fu.data " .
      "FROM {$wpdb->prefix}ninja_forms_uploads AS fu WHERE fu.id = %d";
    $row = $wpdb->get_row($wpdb->prepare($query, array($uploadid)), ARRAY_A);
    $data = unserialize($row['data']);
    // print_r($data); // debugging
    $filepath = $data['file_path'] . $data['file_name'];
    $contents = file_get_contents($filepath);
    if ($contents === false) {
      $out['errmsg'] = "Unable to read \"$filepath\"";
      return;
    }
    $out['filename'] = $data['user_file_name'];
    $out['mimetype'] = get_mime_type($filepath);
    $out['datetime'] = $row['date_updated'];
    // $out['contents'] = base64_encode($contents);
    $out['contents'] = $contents;
  }
}

// Logic to process the "getmessage" action.
// The $messageid argument identifies the message.
//
function action_getmessage($messageid) {
  global $wpdb, $out, $admin_user_login;
  $out['message'] = array();
  $out['uploads'] = array();
  $query = "SELECT cm.id, cm.date, cm.message_title, cm.message_contents, " .
    "uf.user_login AS from_login, ut.user_login AS to_login " .
    "FROM {$wpdb->prefix}cartpauj_pm_messages AS cm " .
    "LEFT JOIN $wpdb->users AS uf ON uf.ID = cm.from_user " .
    "LEFT JOIN $wpdb->users AS ut ON ut.ID = cm.to_user " .
    "WHERE cm.id = %d";
  $queryp = $wpdb->prepare($query, array($messageid));
  if (empty($queryp)) {
    $out['errmsg'] = "Internal error: \"$query\" \"$postid\"";
    return;
  }
  $row = $wpdb->get_row($queryp, ARRAY_A);
  if (empty($row)) {
    $out['errmsg'] = "No messages matching: \"$messageid\"";
    return;
  }
  $out['message'] = array(
    'messageid' => $row['id'],
    'user'      => ($row['from_login'] == $admin_user_login ? $row['to_login'] : $row['from_login']),
    'fromuser'  => $row['from_login'],
    'touser'    => $row['to_login'],
    'datetime'  => $row['date'],
    'title'     => $row['message_title'],
    'contents'  => $row['message_contents'],
  );
  $query2 = "SELECT id, filename, mimetype " .
    "FROM {$wpdb->prefix}cartpauj_pm_attachments " .
    "WHERE message_id = %d ORDER BY filename, id";
  $query2p = $wpdb->prepare($query2, array($messageid));
  if (empty($query2p)) {
    $out['errmsg'] = "Internal error: \"$query2\" \"$messageid\"";
    return;
  }
  $msgrows = $wpdb->get_results($query2p, ARRAY_A);
  foreach ($msgrows as $msgrow) {
    $out['uploads'][] = array(
      'filename' => $msgrow['filename'],
      'mimetype' => $msgrow['mimetype'],
      'id'       => $msgrow['id'],
    );
  }
}

// Logic to process the "getmsgup" action.
// Returns filename, mimetype and contents for the specified upload ID.
//
function action_getmsgup($uploadid) {
  global $wpdb, $out;
  $query = "SELECT id, filename, mimetype, contents " .
    "FROM {$wpdb->prefix}cartpauj_pm_attachments " .
    "WHERE id = %d";
  $row = $wpdb->get_row($wpdb->prepare($query, array($uploadid)), ARRAY_A);
  $out['filename'] = $row['filename'];
  $out['mimetype'] = $row['mimetype'];
  // $out['contents'] = base64_encode($row['contents']);
  $out['contents'] = $row['contents'];
}

// Logic to process the "delmessage" action to delete a message.  It's not
// physically deleted until both sender and recipient delete it.  Note that we
// can delete (actually hide) a child message, but in WordPress that action is
// not supported; there only a parent message can be deleted.  In either case
// a physical delete also deletes all children and associated attachments.
//
function action_delmessage($messageid) {
  global $wpdb, $out, $admin_user_login;
  // Get message attributes so we can figure out what to do.
  $query = "SELECT cm.from_del, cm.to_del, " .
    "uf.user_login AS from_login, ut.user_login AS to_login " .
    "FROM {$wpdb->prefix}cartpauj_pm_messages AS cm " .
    "LEFT JOIN $wpdb->users AS uf ON uf.ID = cm.from_user " .
    "LEFT JOIN $wpdb->users AS ut ON ut.ID = cm.to_user " .
    "WHERE cm.id = %d";
  $row = $wpdb->get_row($wpdb->prepare($query, array($messageid)), ARRAY_A);
  if (empty($row)) {
    $out['errmsg'] = "Cannot delete, there is no message with ID $messageid.";
    return;
  }
  if ($row['from_login'] == $admin_user_login && $row['to_del'] > 0 ||
      $row['to_login'] == $admin_user_login && $row['from_del'] > 0) {
    // Other party has flagged it for deletion so purge the message, its
    // children and all related attachments.
    $wpdb->query($wpdb->prepare("DELETE FROM a " .
      "USING {$wpdb->prefix}cartpauj_pm_messages AS m " .
      "JOIN {$wpdb->prefix}cartpauj_pm_attachments AS a " .
      "WHERE (m.id = %d OR m.parent_id = %d) AND a.message_id = m.id",
      $messageid, $messageid));
    $wpdb->query($wpdb->prepare("DELETE FROM " .
      "{$wpdb->prefix}cartpauj_pm_messages WHERE id = %d OR parent_id = %d",
      $messageid, $messageid));
  }
  else if ($row['from_login'] == $admin_user_login) {
    // We are the sender, recipient has not yet deleted.
    $wpdb->query($wpdb->prepare("UPDATE {$wpdb->prefix}cartpauj_pm_messages " .
      "SET from_del = 1 WHERE id = %d", $messageid));
  }
  else if ($row['to_login'] == $admin_user_login) {
    // We are the recipient, sender has not yet deleted.
    $wpdb->query($wpdb->prepare("UPDATE {$wpdb->prefix}cartpauj_pm_messages " .
      "SET to_del = 1 WHERE id = %d", $messageid));
  }
  else {
    // This should not happen.
    $out['errmsg'] = "Delete refused because '$admin_user_login' is not the " .
      "sender or recipient of message $messageid.";
  }
}

// Logic to process the "putmessage" action.
// Sends a message to the designated user with an optional attachment.
//
function action_putmessage(&$args) {
  global $wpdb, $out, $admin_user_login;
  $sender = convertToID($admin_user_login);
  if (!$sender) {
    $out['errmsg'] = "No such sender '$admin_user_login'";
    return;
  }
  $recipient = convertToID($args['user']);
  if (!$recipient) {
    $out['errmsg'] = "No such recipient '{$args['user']}'";
    return;
  }
  $tmp = $wpdb->insert("{$wpdb->prefix}cartpauj_pm_messages", array(
    'from_user'        => $sender,
    'to_user'          => $recipient,
    'message_title'    => $args['title'],
    'message_contents' => $args['message'],
    'last_sender'      => $sender,
    'date'             => current_time('mysql', 1),
    'last_date'        => current_time('mysql', 1),
  ), array('%d', '%d', '%s', '%s', '%d', '%s', '%s'));
  if ($tmp === false) {
    $out['errmsg'] = "Message insert failed";
    return;
  }
  if (!empty($args['contents'])) {
    $message_id = $wpdb->insert_id;
    $tmp = $wpdb->insert("{$wpdb->prefix}cartpauj_pm_attachments", array(
      'message_id' => $message_id,
      'filename'   => $args['filename'],
      'mimetype'   => $args['mimetype'],
      'contents'   => base64_decode($args['contents']),
    ), array('%d', '%s', '%s', '%s'));
    if ($tmp === false) {
      $out['errmsg'] = "Attachment insert failed";
    }
  }
}

