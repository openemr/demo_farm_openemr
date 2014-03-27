-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 19. Mrz 2014 um 19:07
-- Server Version: 5.5.35
-- PHP-Version: 5.3.10-1ubuntu3.10

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Datenbank: `openemr`
--

--
-- Daten für Tabelle `forms`
--

INSERT INTO `forms` (`id`, `date`, `encounter`, `form_name`, `form_id`, `pid`, `user`, `groupname`, `authorized`, `deleted`, `formdir`) VALUES
(96, '2014-03-19 09:09:14', 16, 'Track: 24h Urin', 20, 2, 'produnis', 'Default', 1, 0, 'track_anything'),
(97, '2014-03-19 09:13:05', 36, 'Track: 24h Urin', 21, 2, 'produnis', 'Default', 1, 0, 'track_anything'),
(98, '2014-03-19 10:53:24', 40, 'Track: Gloodglucose', 22, 2, 'produnis', 'Default', 1, 0, 'track_anything'),
(99, '2014-03-19 10:55:32', 41, 'Track: Gloodglucose', 23, 2, 'produnis', 'Default', 1, 0, 'track_anything'),
(101, '2014-03-19 14:37:35', 36, 'Track: Gloodglucose', 25, 2, 'produnis', 'Default', 1, 0, 'track_anything'),
(100, '2014-03-19 10:56:56', 69, 'Track: Gloodglucose', 24, 2, 'produnis', 'Default', 1, 0, 'track_anything');

--
-- Daten für Tabelle `form_track_anything`
--

INSERT INTO `form_track_anything` (`id`, `date`, `pid`, `procedure_type_id`, `comment`) VALUES
(25, '2014-03-19 13:37:35', NULL, 17, NULL),
(24, '2014-03-19 09:56:56', NULL, 17, NULL),
(23, '2014-03-19 09:55:32', NULL, 17, NULL),
(22, '2014-03-19 09:53:24', NULL, 17, NULL),
(21, '2014-03-19 08:13:05', NULL, 62, NULL),
(20, '2014-03-19 08:09:14', NULL, 62, NULL);

--
-- Daten für Tabelle `form_track_anything_results`
--

INSERT INTO `form_track_anything_results` (`id`, `track_anything_id`, `track_timestamp`, `itemid`, `result`, `comment`, `notes`) VALUES
(1562, 21, '2014-03-16 09:13:21', 65, '49', NULL, NULL),
(1561, 21, '2014-03-16 09:13:21', 64, '41', NULL, NULL),
(1560, 21, '2014-03-16 09:13:21', 63, '410', NULL, NULL),
(1559, 21, '2014-03-15 09:13:05', 65, '50', NULL, NULL),
(1558, 21, '2014-03-15 09:13:05', 64, '40', NULL, NULL),
(1557, 21, '2014-03-15 09:13:05', 63, '400', NULL, NULL),
(1556, 20, '2014-03-14 09:10:26', 65, '25', NULL, NULL),
(1555, 20, '2014-03-14 09:10:26', 64, '32', NULL, NULL),
(1554, 20, '2014-03-14 09:10:26', 63, '250', NULL, NULL),
(1553, 20, '2014-03-13 09:10:00', 65, '20', NULL, NULL),
(1552, 20, '2014-03-13 09:10:00', 64, '30', NULL, NULL),
(1551, 20, '2014-03-13 09:10:00', 63, '270', NULL, NULL),
(1550, 20, '2014-03-12 09:09:33', 65, '27', NULL, NULL),
(1549, 20, '2014-03-12 09:09:33', 64, '39', NULL, NULL),
(1548, 20, '2014-03-12 09:09:33', 63, '220', NULL, NULL),
(1547, 20, '2014-03-11 09:09:14', 65, '28', NULL, NULL),
(1546, 20, '2014-03-11 09:09:14', 64, '24', NULL, NULL),
(1545, 20, '2014-03-11 09:09:14', 63, '300', NULL, NULL),
(1585, 25, '2014-03-19 18:37:56', 19, '120', NULL, NULL),
(1584, 25, '2014-03-19 14:37:51', 19, '77', NULL, NULL),
(1583, 25, '2014-03-19 12:37:35', 19, '89', NULL, NULL),
(1582, 24, '2014-03-19 07:57:04', 19, '184', NULL, NULL),
(1581, 24, '2014-03-19 10:57:02', 19, '100', NULL, NULL),
(1580, 24, '2014-03-19 10:57:00', 19, '120', NULL, NULL),
(1579, 24, '2014-03-19 10:56:56', 19, '180', NULL, NULL),
(1578, 23, '2014-03-09 22:53:51', 19, '89', NULL, NULL),
(1577, 23, '2014-03-09 18:53:51', 19, '153', NULL, NULL),
(1576, 23, '2014-03-09 14:53:51', 19, '143', NULL, NULL),
(1575, 23, '2014-03-09 11:53:51', 19, '88', NULL, NULL),
(1574, 23, '2014-03-09 08:53:51', 19, '65', NULL, NULL),
(1573, 22, '2014-03-08 22:53:51', 19, '79', NULL, NULL),
(1572, 22, '2014-03-08 18:53:51', 19, '170', NULL, NULL),
(1570, 22, '2014-03-08 12:53:51', 19, '120', NULL, NULL),
(1569, 22, '2014-03-08 08:53:51', 19, '88', NULL, NULL),
(1568, 21, '2014-03-18 09:14:08', 65, '50', NULL, NULL),
(1567, 21, '2014-03-18 09:14:08', 64, '44', NULL, NULL),
(1566, 21, '2014-03-18 09:14:08', 63, '390', NULL, NULL),
(1571, 22, '2014-03-08 14:53:51', 19, '101', NULL, NULL),
(1565, 21, '2014-03-17 09:13:56', 65, '51', NULL, NULL),
(1564, 21, '2014-03-17 09:13:56', 64, '42', NULL, NULL),
(1563, 21, '2014-03-17 09:13:56', 63, '420', NULL, NULL);

--
-- Daten für Tabelle `patient_data`
--

INSERT INTO `patient_data` (`id`, `title`, `language`, `financial`, `fname`, `lname`, `mname`, `DOB`, `street`, `postal_code`, `city`, `state`, `country_code`, `drivers_license`, `ss`, `occupation`, `phone_home`, `phone_biz`, `phone_contact`, `phone_cell`, `pharmacy_id`, `status`, `contact_relationship`, `date`, `sex`, `referrer`, `referrerID`, `providerID`, `email`, `ethnoracial`, `race`, `ethnicity`, `interpretter`, `migrantseasonal`, `family_size`, `monthly_income`, `homeless`, `financial_review`, `pubpid`, `pid`, `genericname1`, `genericval1`, `genericname2`, `genericval2`, `hipaa_mail`, `hipaa_voice`, `hipaa_notice`, `hipaa_message`, `hipaa_allowsms`, `hipaa_allowemail`, `squad`, `fitness`, `referral_source`, `usertext1`, `usertext2`, `usertext3`, `usertext4`, `usertext5`, `usertext6`, `usertext7`, `usertext8`, `userlist1`, `userlist2`, `userlist3`, `userlist4`, `userlist5`, `userlist6`, `userlist7`, `pricelevel`, `regdate`, `contrastart`, `completed_ad`, `ad_reviewed`, `vfc`, `mothersname`, `guardiansname`, `allow_imm_reg_use`, `allow_imm_info_share`, `allow_health_info_ex`, `allow_patient_portal`, `deceased_date`, `deceased_reason`, `soap_import_status`, `ref_providerID`, `email_direct`) VALUES
(1, '', 'german', '', 'Sophia', 'Loren', '', '1965-09-12', '', '', '', 'NRW', 'Deutschland', '', '', '', '', '', '', '', 0, '', '', '2014-03-19 08:58:25', 'Female', '', '', 0, '', '', '', '', '', '', '', '', '', '0000-00-00 00:00:00', '1', 1, '', '', '', '', '', '', '', '', '', '', '', 0, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'standard', NULL, NULL, 'NO', NULL, '', '', '', '', '', '', '', '0000-00-00 00:00:00', '', NULL, 0, ''),
(2, 'Herr', 'german', '', 'Zoid', 'Berg', '', '1976-09-14', '', '45881', '', 'NRW', 'Deutschland', '', '', 'Selbstständig', '', '', '', '', 0, 'married', '', '2014-03-19 09:08:19', 'Male', '', '', 0, '', '', '', '', '', '', '', '', '', '0000-00-00 00:00:00', '2', 2, '', '', '', '', '', '', '', '', '', 'YES', '', 0, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'standard', NULL, NULL, 'NO', NULL, '', '', '', '', '', 'YES', 'YES', '0000-00-00 00:00:00', '', NULL, 0, '');

--
-- Daten für Tabelle `procedure_order`
--

INSERT INTO `procedure_order` (`procedure_order_id`, `provider_id`, `patient_id`, `encounter_id`, `date_collected`, `date_ordered`, `order_priority`, `order_status`, `patient_instructions`, `activity`, `control_id`, `lab_id`, `specimen_type`, `specimen_location`, `specimen_volume`, `date_transmitted`, `clinical_hx`) VALUES
(5, 2, 2, 19, '2014-02-25 14:32:00', '2014-02-03', '', '', '', 1, 0, 1, '', '', '', NULL, ''),
(6, 2, 2, 19, '2014-02-25 14:32:00', '2014-02-03', 'high', '', '', 1, 0, 1, '', '', '', NULL, 'Blutuntersuchung beim Hausarzt'),
(7, 2, 2, 18, '2014-02-25 14:52:00', '2014-02-25', 'normal', 'complete', '', 1, 0, 1, '', '', '', NULL, ''),
(8, 2, 2, 30, '2014-02-25 19:41:00', '2014-02-18', 'high', '', '', 1, 0, 1, '', '', '', NULL, ''),
(9, 2, 2, 31, '2014-02-25 19:52:00', '2014-02-06', 'high', '', '', 1, 0, 1, '', '', '', NULL, ''),
(10, 2, 2, 31, '2014-02-25 19:53:00', '2014-02-06', 'high', '', '', 1, 0, 1, '', '', '', NULL, ''),
(11, 2, 2, 16, '2014-02-27 14:36:00', '2014-02-25', 'high', 'complete', '', 1, 0, 1, '', '', '', NULL, ''),
(12, 2, 2, 16, '2014-02-27 14:47:00', '2014-02-24', '', 'pending', '', 1, 0, 1, '', '', '', NULL, '');

--
-- Daten für Tabelle `procedure_order_code`
--

INSERT INTO `procedure_order_code` (`procedure_order_id`, `procedure_order_seq`, `procedure_code`, `procedure_source`, `procedure_name`, `diagnoses`, `do_not_send`) VALUES
(4, 1, '', '1', 'Blutabnahme', '', 0),
(3, 1, '', '1', 'Blutabnahme', '', 0),
(6, 1, 'Blutabnahme', '1', 'Blutabnahme', '', 0),
(7, 1, 'Blutabnahme', '1', 'Blutabnahme', '', 0),
(8, 1, 'Blutabnahme', '1', 'Blutabnahme', '', 0),
(10, 1, 'Blutabnahme', '1', 'Blutabnahme', '', 0),
(11, 1, '24hUrin', '1', '24h Urin', '', 0),
(11, 2, 'Blutabnahme', '1', 'Blutabnahme', '', 0),
(12, 1, 'Stuhlprobe', '1', 'Stuhlprobe', '', 0);

--
-- Daten für Tabelle `procedure_providers`
--

INSERT INTO `procedure_providers` (`ppid`, `name`, `npi`, `protocol`, `login`, `password`, `orders_path`, `results_path`, `notes`, `remote_host`, `send_app_id`, `send_fac_id`, `recv_app_id`, `recv_fac_id`, `DorP`) VALUES
(1, 'Labor Hausarzt', '', 'DL', '', '', '', '', '', '', '', '', '', '', 'D'),
(2, 'Labor Klinik', '', 'DL', '', '', '', '', '', '', '', '', '', '', 'D');

--
-- Daten für Tabelle `procedure_report`
--

INSERT INTO `procedure_report` (`procedure_report_id`, `procedure_order_id`, `date_collected`, `date_report`, `source`, `specimen_num`, `report_status`, `review_status`, `procedure_order_seq`, `report_notes`) VALUES
(4, 7, '2014-02-18 14:53:00', '2014-02-19', 0, 'Blut', 'final', 'reviewed', 1, ''),
(3, 6, '2014-02-03 14:36:00', '2014-02-03', 0, 'Blut', 'final', 'reviewed', 1, ''),
(5, 8, '2014-02-18 19:42:00', '2014-02-18', 0, 'Blut', 'final', 'reviewed', 1, ''),
(6, 10, '2014-02-06 19:53:00', '2014-02-06', 0, 'Blut', 'final', 'reviewed', 1, ''),
(7, 11, '2014-02-26 14:38:00', '2014-02-26', 0, 'Urin', 'final', 'reviewed', 1, ''),
(8, 12, '2014-02-24 14:47:00', '2014-02-26', 0, 'Faeces', 'final', 'reviewed', 1, ''),
(9, 11, '2014-02-25 14:58:00', '2014-02-25', 0, 'Blut', 'prelim', 'reviewed', 2, '');

--
-- Daten für Tabelle `procedure_result`
--

INSERT INTO `procedure_result` (`procedure_result_id`, `procedure_report_id`, `date`, `facility`, `units`, `result`, `range`, `abnormal`, `comments`, `document_id`, `result_status`, `result_data_type`, `result_code`, `result_text`) VALUES
(75, 3, NULL, '', 'g_dl', '12.7', '12.3 - 15.3', 'no', '', 0, 'final', 'S', 'Hglobin', 'Hämoglobin'),
(74, 3, NULL, '', 'percent', '38', '35 - 45', 'no', '', 0, 'final', 'S', 'Hkrit', 'Hämatokrit'),
(73, 3, NULL, '', 'units_l', '12', '10 -35', 'no', '', 0, 'final', 'S', 'GPT', 'GPT'),
(72, 3, NULL, '', 'units_l', '18', '10 - 35', 'no', '', 0, 'final', 'S', 'GOT', 'GOT'),
(70, 3, NULL, '', 'units_l', '11', '< 40', 'no', '', 0, 'final', 'S', 'GGT', 'Gamma-GT'),
(67, 3, NULL, '', 'units_l', '4.9', '4.10 - 5.10', 'no', '', 0, 'final', 'S', 'Ery', 'Erythrozyten'),
(66, 3, NULL, '', 'units_l', '69', '33 - 193', 'no', '', 0, 'final', 'S', 'Fe', 'Eisen'),
(63, 3, NULL, '', 'units_l', '165', '< 200', '', '', 0, 'final', 'S', 'Chol', 'Cholesterin'),
(60, 3, NULL, '', 'mg_dl', '< 0.1', '< 0.500', 'no', '', 0, 'final', 'S', 'crP', 'C-reakt. Protein'),
(59, 3, NULL, '', 'units_l', '78', '55 - 115', 'no', '', 0, 'final', 'S', 'BZ', 'Blutzucker-Serum'),
(57, 3, NULL, '', 'mg_dl', '0.2', '0.120 - 1.11', 'no', '', 0, 'final', 'S', 'Bilir', 'Bilirubin'),
(78, 3, NULL, '', 'mg_dl', '0.7', '0.50 - 0.90', 'no', '', 0, 'final', 'S', 'Kreatinin', 'Kreatinin'),
(80, 3, NULL, '', 'units_l', '9.0', '4.30 - 10.0', 'no', '', 0, 'final', 'S', 'Leukoz', 'Leukozyten'),
(82, 3, NULL, '', 'pg', '26', '27 - 34', 'low', '', 0, 'final', 'S', 'MCH', 'MCH'),
(83, 3, NULL, '', 'g_dl', '33', '31.5 - 36', 'no', '', 0, 'final', 'S', 'MCHC', 'MCHC'),
(84, 3, NULL, '', 'fl', '78', '82 - 101', 'low', '', 0, 'final', 'S', 'MCV', 'MCV'),
(86, 3, NULL, '', 'units_l', '73', '35 - 104', 'no', '', 0, 'final', 'S', 'alkPhos', 'Phosphatase (alk.)'),
(93, 3, NULL, '', 'oth', '325', '150 - 400', 'no', '', 0, 'final', 'S', 'Trombz', 'Thrombocyten'),
(94, 3, NULL, '', 'oth', '1.39', '0.30-2.5/4.0', 'no', '', 0, 'final', 'S', 'TSHbasal', 'TSH basal'),
(95, 3, NULL, '', 'mg_dl', '290', '300 - 910', 'low', 'leichter Mangel', 0, 'final', 'S', 'Vit-B12', 'Vitamin B12'),
(413, 9, NULL, '', '', '', '60.0 - 120.0', '', '', 0, 'final', 'S', 'Zink', 'Zink'),
(412, 9, NULL, '', '', '74', '30 - 100', 'no', 'guter Wert,~VitaminD-Mangel damit behoben', 0, 'final', 'S', 'Vit-D3', 'Vitamin D3'),
(411, 9, NULL, '', '', '', '300 - 910', '', '', 0, 'final', 'S', 'Vit-B12', 'Vitamin B12'),
(410, 9, NULL, '', '', '', '9.30 - 17.00', '', '', 0, 'final', 'S', 'FT4', 'TSH-FT4'),
(403, 9, NULL, '', '', '', '< 14', '', '', 0, 'final', 'S', 'Rheuma', 'Rheumafaktor'),
(404, 9, NULL, '', '', '', '50 -120', '', '', 0, 'final', 'S', 'Selen', 'Selen im Serum'),
(405, 9, NULL, '', 'oth', '', '150 - 400', '', '', 0, 'final', 'S', 'Thrombz', 'Thrombocyten'),
(406, 9, NULL, '', 'oth', '', '0 - 35', '', '', 0, 'final', 'S', 'TPO', 'TPO'),
(407, 9, NULL, '', 'oth', '', '0.30-2.5/4.0', '', '', 0, 'final', 'S', 'TSHbasal', 'TSH basal'),
(408, 9, NULL, '', 'units_l', '', '0 - 1.0', '', '', 0, 'final', 'S', 'TSH-R-AK', 'TSH Rezeptor AK'),
(409, 9, NULL, '', 'oth', '', '2.20 - 4.40', '', '', 0, 'final', 'S', 'FT3', 'TSH-FT3'),
(140, 4, NULL, '', '', '30', '< 200', 'no', '', 0, 'final', 'S', 'ASL', 'ASL'),
(141, 4, NULL, '', 'mg_dl', '0.5', '0.120 - 1.11', 'no', '', 0, 'final', 'S', 'Bilir', 'Bilirubin'),
(142, 4, NULL, '', '', '9.5', '< 70', 'no', '', 0, 'final', 'S', 'Plumbum', 'Blei im EDTA-Blut'),
(143, 4, NULL, '', '', '71', '55 - 115', 'no', '', 0, 'final', 'S', 'BZ', 'Blutzucker-Serum'),
(144, 4, NULL, '', 'mg_dl', '< 0.01', '< 0.500', 'no', '', 0, 'final', 'S', 'crP', 'C-reakt. Protein'),
(145, 4, NULL, '', 'hmol_l', '2.29', '2.15 - 2.50', 'no', '', 0, 'final', 'S', 'Calc', 'Calcium'),
(146, 4, NULL, '', 'hmol_l', '106', '98 - 106', 'no', '', 0, 'final', 'S', 'Chlorid', 'Chlorid'),
(147, 4, NULL, '', '', '156', '< 200', 'no', '', 0, 'final', 'S', 'Chol', 'Cholesterin'),
(149, 4, NULL, '', '', '1.0', '< 7', 'no', '', 0, 'final', 'S', 'ccP-AK', 'cyc. citrulliniert. Peptid-AK'),
(402, 9, NULL, '', 'percent', '', '12 -14', '', '', 0, 'final', 'S', 'RDW-CV', 'RDW-CV'),
(151, 4, NULL, '', '', '5.11', '4.10 - 5.10', 'high', 'evtl bedingt durch viele Blutabnahmen', 0, 'final', 'S', 'Ery', 'Erythrozyten'),
(153, 4, NULL, '', '', '9.5', '> 5.4', 'no', '', 0, 'final', 'S', 'Fols', 'Folsaeure'),
(401, 9, NULL, '', 'percent', '', '70 - 120', '', '', 0, 'final', 'S', 'Quick', 'Quick'),
(400, 9, NULL, '', 'oth', '', '26 - 40', '', '', 0, 'final', 'S', 'PTT', 'PTT'),
(156, 4, NULL, '', 'units_l', '14', '10 - 35', 'no', '', 0, 'final', 'S', 'GOT', 'GOT'),
(157, 4, NULL, '', 'units_l', '13', '10 -35', 'no', '', 0, 'final', 'S', 'GPT', 'GPT'),
(158, 4, NULL, '', 'percent', '40', '35 - 45', 'no', '', 0, 'final', 'S', 'Hkrit', 'Hämatokrit'),
(159, 4, NULL, '', 'g_dl', '12.9', '12.3 - 15.3', 'no', '', 0, 'final', 'S', 'Hglobin', 'Hämoglobin'),
(160, 4, NULL, '', 'mg_dl', '28', '10.2 - 49.9', 'no', '', 0, 'final', 'S', 'Harnst', 'Harnstoff'),
(161, 4, NULL, '', 'hmol_l', '4.52', '3.6 - 4.8', 'no', '', 0, 'final', 'S', 'Kalium', 'Kalium'),
(162, 4, NULL, '', 'mg_dl', '0.7', '0.50 - 0.90', 'no', '', 0, 'final', 'S', 'Kreatinin', 'Kreatinin'),
(164, 4, NULL, '', '', '6.66', '4.30 - 10.0', 'no', '', 0, 'final', 'S', 'Leukoz', 'Leukozyten'),
(165, 4, NULL, '', 'units_l', '46', '< 60', 'no', '', 0, 'final', 'S', 'Lipase', 'Lipase'),
(166, 4, NULL, '', 'pg', '25', '27 - 34', 'low', '', 0, 'final', 'S', 'MCH', 'MCH'),
(167, 4, NULL, '', 'g_dl', '32', '31.5 - 36', 'no', '', 0, 'final', 'S', 'MCHC', 'MCHC'),
(168, 4, NULL, '', 'fl', '79', '82 - 101', 'low', '', 0, 'final', 'S', 'MCV', 'MCV'),
(169, 4, NULL, '', 'hmol_l', '141', '135 - 144', 'no', '', 0, 'final', 'S', 'Na', 'Natrium'),
(399, 9, NULL, '', 'g_dl', '', '6.00 - 8.00', '', '', 0, 'final', 'S', 'ProtTotal', 'Protein Total'),
(398, 9, NULL, '', 'units_l', '', '35 - 104', '', '', 0, 'final', 'S', 'alkPhos', 'Phosphatase (alk.)'),
(397, 9, NULL, '', 'hmol_l', '', '0.87 - 1.45', '', '', 0, 'final', 'S', 'PhosAnor', 'Phosphat Anor'),
(174, 4, NULL, '', 'percent', '14.0', '12 -14', 'no', '', 0, 'final', 'S', 'RDW-CV', 'RDW-CV'),
(175, 4, NULL, '', '', '< 9.3', '< 14', 'no', '', 0, 'final', 'S', 'Rheuma', 'Rheumafaktor'),
(176, 4, NULL, '', '', '77', '50 -120', 'no', '', 0, 'final', 'S', 'Selen', 'Selen im Serum'),
(177, 4, NULL, '', 'oth', '294', '150 - 400', 'no', '', 0, 'final', 'S', 'Thrombz', 'Thrombocyten'),
(178, 4, NULL, '', 'oth', '1.60', '0.30-2.5/4.0', 'no', '', 0, 'final', 'S', 'TSHbasal', 'TSH basal'),
(179, 4, NULL, '', '', '291', '300 - 910', 'low', 'leichter Mangel', 0, 'final', 'S', 'Vit-B12', 'Vitamin B12'),
(180, 4, NULL, '', '', '6.9', '30 - 100', 'low', 'schwerer Mangel!', 0, 'final', 'S', 'Vit-D3', 'Vitamin D3'),
(181, 4, NULL, '', '', '91.2', '60.0 - 120.0', 'no', '', 0, 'final', 'S', 'Zink', 'Zink'),
(396, 9, NULL, '', 'hmol_l', '', '135 - 144', '', '', 0, 'final', 'S', 'Na', 'Natrium'),
(395, 9, NULL, '', 'fl', '', '82 - 101', '', '', 0, 'final', 'S', 'MCV', 'MCV'),
(184, 4, NULL, '', '', '> 80', '> 80', 'no', '', 0, 'final', 'S', 'GFR-MDRD', 'GFR nach MDRD-Formel'),
(185, 4, NULL, '', 'units_l', '8', '< 40', 'no', '', 0, 'final', 'S', 'GGT', 'GGT'),
(186, 4, NULL, '', '', '4.3', '< 6.0', 'no', '', 0, 'final', 'S', 'Harnsäure', 'Harnsäure'),
(394, 9, NULL, '', 'g_dl', '', '31.5 - 36', '', '', 0, 'final', 'S', 'MCHC', 'MCHC'),
(393, 9, NULL, '', 'pg', '', '27 - 34', '', '', 0, 'final', 'S', 'MCH', 'MCH'),
(190, 4, NULL, '', 'hmol_l', '0.98', '0.53 - 1.11', 'no', '', 0, 'final', 'S', 'Magnesium', 'Magnesium'),
(392, 9, NULL, '', 'hmol_l', '', '0.53 - 1.11', '', '', 0, 'final', 'S', 'Magnesium', 'Magnesium'),
(391, 9, NULL, '', 'units_l', '', '< 60', '', '', 0, 'final', 'S', 'Lipase', 'Lipase'),
(390, 9, NULL, '', '', '', '4.30 - 10.0', '', '', 0, 'final', 'S', 'Leukoz', 'Leukozyten'),
(194, 4, NULL, '', 'oth', '3.0', '2.20 - 4.40', 'no', '', 0, 'final', 'S', 'FT3', 'TSH-FT3'),
(195, 4, NULL, '', '', '1.20', '9.30 - 17.00', 'no', '', 0, 'final', 'S', 'FT4', 'TSH-FT4'),
(196, 5, NULL, '', 'oth', '12.90', '4.70 - 48.80', 'no', '', 0, 'final', 'S', 'ACTH', 'ACTH'),
(389, 9, NULL, '', 'units_l', '', '< 250', '', '', 0, 'final', 'S', 'LDH', 'LDH'),
(388, 9, NULL, '', 'mg_dl', '', '0.50 - 0.90', '', '', 0, 'final', 'S', 'Kreatinin', 'Kreatinin'),
(345, 7, NULL, '', 'mmol/L', '12', '64 - 172', 'low', '', 0, 'final', 'S', 'Natrium', 'Natrium'),
(346, 7, NULL, '', 'mmol/24h', '90.0', '40 - 220', 'no', '', 0, 'final', 'S', 'Natrium24h', 'Natrium 24h'),
(202, 5, NULL, '', 'hmol_l', '2.13', '2.15 - 2.50', 'low', '', 0, 'final', 'S', 'Calc', 'Calcium'),
(387, 9, NULL, '', 'hmol_l', '', '3.6 - 4.8', '', '', 0, 'final', 'S', 'Kalium', 'Kalium'),
(386, 9, NULL, '', 'pg', '', '27.0 - 34.9', '', '', 0, 'final', 'S', 'HBE', 'HBE'),
(206, 5, NULL, '', '', '133.4', '62.0 - 194.0', 'no', '', 0, 'final', 'S', 'Cortisol', 'Cortisol'),
(385, 9, NULL, '', 'oth', '', '20 - 42', '', '', 0, 'final', 'S', 'HBA1Cif', 'HBA1Cif'),
(384, 9, NULL, '', 'percent', '', '4.0 - 6.0', '', '', 0, 'final', 'S', 'HBA1c', 'HBA1c'),
(209, 5, NULL, '', '', '4.59', '4.10 - 5.10', 'no', '', 0, 'final', 'S', 'Ery', 'Erythrozyten'),
(210, 5, NULL, '', '', '30.30', '10 -291', 'no', '', 0, 'final', 'S', 'Ferritin', 'Ferritin'),
(383, 9, NULL, '', 'mg_dl', '', '10.2 - 49.9', '', '', 0, 'final', 'S', 'Harnst', 'Harnstoff'),
(382, 9, NULL, '', '', '', '< 6.0', '', '', 0, 'final', 'S', 'Harnsäure', 'Harnsäure'),
(381, 9, NULL, '', 'g_dl', '', '12.3 - 15.3', '', '', 0, 'final', 'S', 'Hglobin', 'Hämoglobin'),
(380, 9, NULL, '', 'percent', '', '35 - 45', '', '', 0, 'final', 'S', 'Hkrit', 'Hämatokrit'),
(218, 5, NULL, '', 'percent', '37.5', '35 - 45', 'no', '', 0, 'final', 'S', 'Hkrit', 'Hämatokrit'),
(219, 5, NULL, '', 'g_dl', '12.5', '12.3 - 15.3', 'no', '', 0, 'final', 'S', 'Hglobin', 'Hämoglobin'),
(379, 9, NULL, '', 'units_l', '', '10 -35', '', '', 0, 'final', 'S', 'GPT', 'GPT'),
(378, 9, NULL, '', 'units_l', '', '10 - 35', '', '', 0, 'final', 'S', 'GOT', 'GOT'),
(222, 5, NULL, '', 'percent', '5.3', '4.0 - 6.0', 'no', '', 0, 'final', 'S', 'HBA1c', 'HBA1c'),
(223, 5, NULL, '', 'oth', '35', '20 - 42', 'no', '', 0, 'final', 'S', 'HBA1Cif', 'HBA1Cif'),
(377, 9, NULL, '', 'units_l', '', '< 40', '', '', 0, 'final', 'S', 'GGT', 'GGT'),
(225, 5, NULL, '', 'hmol_l', '4.5', '3.6 - 4.8', 'no', '', 0, 'final', 'S', 'Kalium', 'Kalium'),
(226, 5, NULL, '', 'mg_dl', '0.76', '0.50 - 0.90', 'no', '', 0, 'final', 'S', 'Kreatinin', 'Kreatinin'),
(228, 5, NULL, '', '', '8.4', '4.30 - 10.0', 'no', '', 0, 'final', 'S', 'Leukoz', 'Leukozyten'),
(376, 9, NULL, '', '', '', '> 80', '', '', 0, 'final', 'S', 'GFR-MDRD', 'GFR nach MDRD-Formel'),
(375, 9, NULL, '', 'oth', '', '0.85 - 1.30', '', '', 0, 'final', 'S', 'INR', 'Gerinnung INR'),
(231, 5, NULL, '', 'pg', '27.2', '27 - 34', 'no', '', 0, 'final', 'S', 'MCH', 'MCH'),
(232, 5, NULL, '', 'g_dl', '33.3', '31.5 - 36', 'no', '', 0, 'final', 'S', 'MCHC', 'MCHC'),
(233, 5, NULL, '', 'fl', '81.7', '82 - 101', 'no', '', 0, 'final', 'S', 'MCV', 'MCV'),
(234, 5, NULL, '', 'hmol_l', '140', '135 - 144', 'no', '', 0, 'final', 'S', 'Na', 'Natrium'),
(235, 5, NULL, '', 'hmol_l', '1.36', '0.87 - 1.45', 'no', '', 0, 'final', 'S', 'PhosAnor', 'Phosphat Anor'),
(374, 9, NULL, '', 'units_l', '', '< 40', '', '', 0, 'final', 'S', 'G-GT', 'Gamma-GT'),
(237, 5, NULL, '', 'g_dl', '6.4', '6.00 - 8.00', 'no', '', 0, 'final', 'S', 'ProtTotal', 'Protein Total'),
(373, 9, NULL, '', '', '', '> 5.4', '', '', 0, 'final', 'S', 'Fols', 'Folsaeure'),
(372, 9, NULL, '', '', '', '10 -291', '', '', 0, 'final', 'S', 'Ferritin', 'Ferritin'),
(371, 9, NULL, '', '', '', '4.10 - 5.10', '', '', 0, 'final', 'S', 'Ery', 'Erythrozyten'),
(370, 9, NULL, '', '', '', '33 - 193', '', '', 0, 'final', 'S', 'Fe', 'Eisen'),
(243, 5, NULL, '', 'oth', '310', '150 - 400', 'no', '', 0, 'final', 'S', 'Thrombz', 'Thrombocyten'),
(244, 5, NULL, '', 'oth', '10.80', '0 - 35', 'no', '', 0, 'final', 'S', 'TPO', 'TPO'),
(245, 5, NULL, '', 'oth', '0.93', '0.30-2.5/4.0', 'no', '', 0, 'final', 'S', 'TSHbasal', 'TSH basal'),
(246, 5, NULL, '', 'units_l', '< 0.3', '0 - 1.0', 'no', '', 0, 'final', 'S', 'TSH-R-AK', 'TSH Rezeptor AK'),
(247, 5, NULL, '', 'oth', '2.60', '2.20 - 4.40', 'no', '', 0, 'final', 'S', 'FT3', 'TSH-FT3'),
(248, 5, NULL, '', '', '13.30', '9.30 - 17.00', 'no', '', 0, 'final', 'S', 'FT4', 'TSH-FT4'),
(369, 9, NULL, '', '', '', '< 7', '', '', 0, 'final', 'S', 'ccP-AK', 'cyc. citrulliniert. Peptid-AK'),
(368, 9, NULL, '', '', '', '62.0 - 194.0', '', '', 0, 'final', 'S', 'Cortisol', 'Cortisol'),
(367, 9, NULL, '', 'units_l', '', '< 170', '', '', 0, 'final', 'S', 'CK', 'CK'),
(366, 9, NULL, '', '', '', '< 200', '', '', 0, 'final', 'S', 'Chol', 'Cholesterin'),
(254, 6, NULL, '', 'mg_dl', '0.25', '0.120 - 1.11', 'no', '', 0, 'final', 'S', 'Bilir', 'Bilirubin'),
(365, 9, NULL, '', 'hmol_l', '', '98 - 106', '', '', 0, 'final', 'S', 'Chlorid', 'Chlorid'),
(256, 6, NULL, '', '', '103', '55 - 115', 'no', '', 0, 'final', 'S', 'BZ', 'Blutzucker-Serum'),
(257, 6, NULL, '', 'mg_dl', '< 0.5', '< 0.500', 'no', '', 0, 'final', 'S', 'crP', 'C-reakt. Protein'),
(258, 6, NULL, '', 'hmol_l', '2.40', '2.15 - 2.50', 'no', '', 0, 'final', 'S', 'Calc', 'Calcium'),
(259, 6, NULL, '', 'hmol_l', '106', '98 - 106', 'no', '', 0, 'final', 'S', 'Chlorid', 'Chlorid'),
(364, 9, NULL, '', 'hmol_l', '', '2.15 - 2.50', '', '', 0, 'final', 'S', 'Calc', 'Calcium'),
(261, 6, NULL, '', 'units_l', '56', '< 170', 'no', '', 0, 'final', 'S', 'CK', 'CK'),
(363, 9, NULL, '', 'mg_dl', '', '< 0.500', '', '', 0, 'final', 'S', 'crP', 'C-reakt. Protein'),
(347, 7, NULL, '', 'ml', '7500', '', '', '', 0, 'final', 'S', 'Menge', 'Sammelmenge'),
(265, 6, NULL, '', '', '4.84', '4.10 - 5.10', 'no', '', 0, 'final', 'S', 'Ery', 'Erythrozyten'),
(362, 9, NULL, '', '', '', '55 - 115', '', '', 0, 'final', 'S', 'BZ', 'Blutzucker-Serum'),
(269, 6, NULL, '', 'oth', '1.10', '0.85 - 1.30', 'no', '', 0, 'final', 'S', 'INR', 'Gerinnung INR'),
(361, 9, NULL, '', '', '', '< 70', '', '', 0, 'final', 'S', 'Plumbum', 'Blei im EDTA-Blut'),
(271, 6, NULL, '', 'units_l', '8.6', '< 40', 'no', '', 0, 'final', 'S', 'GGT', 'GGT'),
(272, 6, NULL, '', 'units_l', '19.8', '10 - 35', 'no', '', 0, 'final', 'S', 'GOT', 'GOT'),
(273, 6, NULL, '', 'units_l', '14.7', '10 -35', 'no', '', 0, 'final', 'S', 'GPT', 'GPT'),
(274, 6, NULL, '', 'percent', '38.9', '35 - 45', 'no', '', 0, 'final', 'S', 'Hkrit', 'Hämatokrit'),
(275, 6, NULL, '', 'g_dl', '12.4', '12.3 - 15.3', 'no', '', 0, 'final', 'S', 'Hglobin', 'Hämoglobin'),
(360, 9, NULL, '', 'mg_dl', '', '0.120 - 1.11', '', '', 0, 'final', 'S', 'Bilir', 'Bilirubin'),
(277, 6, NULL, '', 'mg_dl', '10.2', '10.2 - 49.9', 'no', '', 0, 'final', 'S', 'Harnst', 'Harnstoff'),
(359, 9, NULL, '', '', '', '< 200', '', '', 0, 'final', 'S', 'ASL', 'ASL'),
(358, 9, NULL, '', 'oth', '', '4.70 - 48.80', '', '', 0, 'final', 'S', 'ACTH', 'ACTH'),
(281, 6, NULL, '', 'hmol_l', '4.11', '3.6 - 4.8', 'no', '', 0, 'final', 'S', 'Kalium', 'Kalium'),
(282, 6, NULL, '', 'mg_dl', '0.62', '0.50 - 0.90', 'no', '', 0, 'final', 'S', 'Kreatinin', 'Kreatinin'),
(283, 6, NULL, '', 'units_l', '162', '< 250', 'no', '', 0, 'final', 'S', 'LDH', 'LDH'),
(284, 6, NULL, '', '', '9.12', '4.30 - 10.0', 'no', '', 0, 'final', 'S', 'Leukoz', 'Leukozyten'),
(285, 6, NULL, '', 'units_l', '29.3', '< 60', 'no', '', 0, 'final', 'S', 'Lipase', 'Lipase'),
(287, 6, NULL, '', 'pg', '25.6', '27 - 34', 'low', '', 0, 'final', 'S', 'MCH', 'MCH'),
(288, 6, NULL, '', 'g_dl', '32.2', '31.5 - 36', 'no', '', 0, 'final', 'S', 'MCHC', 'MCHC'),
(289, 6, NULL, '', 'fl', '79.5', '82 - 101', 'low', '', 0, 'final', 'S', 'MCV', 'MCV'),
(290, 6, NULL, '', 'hmol_l', '143', '135 - 144', 'no', '', 0, 'final', 'S', 'Na', 'Natrium'),
(357, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Yersinia', 'Yersinia'),
(292, 6, NULL, '', 'units_l', '64.6', '35 - 104', 'no', '', 0, 'final', 'S', 'alkPhos', 'Phosphatase (alk.)'),
(293, 6, NULL, '', 'g_dl', '7.2', '6.00 - 8.00', 'no', '', 0, 'final', 'S', 'ProtTotal', 'Protein Total'),
(294, 6, NULL, '', 'oth', '47.5', '26 - 40', 'high', '', 0, 'final', 'S', 'PTT', 'PTT'),
(295, 6, NULL, '', 'percent', '85', '70 - 120', 'no', '', 0, 'final', 'S', 'Quick', 'Quick'),
(356, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Würmer', 'Würmer (parasitär)'),
(355, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Wurmeier', 'Wurmeier'),
(299, 6, NULL, '', 'oth', '324', '150 - 400', 'no', '', 0, 'final', 'S', 'Thrombz', 'Thrombocyten'),
(354, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Shigellen', 'Shigellen'),
(353, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Salmonellen', 'Salmonellen'),
(352, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Lamblienzysten', 'Lamblienzysten'),
(351, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Lamblien', 'Lamblien'),
(350, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Campylobacter', 'Campylobacter'),
(349, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Amöbenzysten', 'Amöbenzysten'),
(348, 8, NULL, '', 'bool', 'NO', '', 'no', '', 0, 'final', 'S', 'Amöben', 'Amöben');

--
-- Daten für Tabelle `procedure_type`
--

INSERT INTO `procedure_type` (`procedure_type_id`, `parent`, `name`, `lab_id`, `procedure_code`, `procedure_type`, `body_site`, `specimen`, `route_admin`, `laterality`, `description`, `standard_code`, `related_code`, `units`, `range`, `seq`, `activity`, `notes`) VALUES
(1, 0, 'BloodAnalysis', 1, 'BloodAnalysis', 'ord', 'arm', 'blood', 'inj', '', 'BloodAnalysis', '', '', '', '', 0, 1, ''),
(2, 1, 'Thrombocyten', 1, 'Thrombz', 'res', '', '', '', '', 'Thrombozyten', '', '', 'oth', '150 - 400', 0, 1, ''),
(3, 1, 'RDW-CV', 1, 'RDW-CV', 'res', '', '', '', '', 'red cell distribution width', '', '', 'percent', '12 -14', 0, 1, ''),
(4, 1, 'TSH basal', 1, 'TSHbasal', 'res', '', '', '', '', 'TSH basal', '', '', 'oth', '0.30-2.5/4.0', 0, 1, ''),
(51, 1, 'TSH-FT3', 1, 'FT3', 'res', '', '', '', '', 'freies T3', '', '', 'oth', '2.20 - 4.40', 0, 1, ''),
(52, 1, 'TSH-FT4', 1, 'FT4', 'res', '', '', '', '', 'freies T4', '', '', '', '9.30 - 17.00', 0, 1, ''),
(7, 1, 'Ferritin', 1, 'Ferritin', 'res', '', '', '', '', 'Ferritin', '', '', '', '10 -291', 0, 1, ''),
(8, 1, 'Folsaeure', 1, 'Fols', 'res', '', '', '', '', 'Folsäure', '', '', '', '> 5.4', 0, 1, ''),
(9, 1, 'Vitamin B12', 1, 'Vit-B12', 'res', '', '', '', '', 'Vitamin B12', '', '', '', '300 - 910', 0, 1, ''),
(10, 1, 'Vitamin D3', 1, 'Vit-D3', 'res', '', '', '', '', 'Vitamin D3', '', '', '', '30 - 100', 0, 1, ''),
(11, 1, 'Zink', 1, 'Zink', 'res', '', '', '', '', 'Zink', '', '', '', '60.0 - 120.0', 0, 1, ''),
(12, 1, 'Selen im Serum', 1, 'Selen', 'res', '', '', '', '', 'Selen im Serum', '', '', '', '50 -120', 0, 1, ''),
(13, 1, 'Blei im EDTA-Blut', 1, 'Plumbum', 'res', '', '', '', '', 'Blei im EDTA-Blut', '', '', '', '< 70', 0, 1, ''),
(14, 1, 'ASL', 1, 'ASL', 'res', '', '', '', '', 'Anti Streptolysin-Titer', '', '', '', '< 200', 0, 1, ''),
(15, 1, 'Rheumafaktor', 1, 'Rheuma', 'res', '', '', '', '', 'IgG IgA IgM', '', '', '', '< 14', 0, 1, ''),
(16, 1, 'cyc. citrulliniert. Peptid-AK', 1, 'ccP-AK', 'res', '', '', '', '', 'cyc. citrulliniert. Peptid-AK', '', '', '', '< 7', 0, 1, ''),
(17, 0, 'Gloodglucose', 1, 'BZtest', 'ord', 'arm', 'blood', 'inj', '', 'Blutzucker (Glycose)', '', '', 'oth', '55 - 115', 0, 1, ''),
(18, 1, 'Blutzucker-Serum', 1, 'BZ', 'res', '', '', '', '', 'Blutzucker-Serum', '', '', '', '55 - 115', 0, 1, ''),
(19, 17, 'Glucose', 1, 'Glucose', 'res', '', '', '', '', 'Glucose', '', '', '', '55 - 115', 0, 1, ''),
(20, 1, 'Leukozyten', 1, 'Leukoz', 'res', '', '', '', '', 'Leukozyten', '', '', '', '4.30 - 10.0', 0, 1, ''),
(21, 1, 'Erythrozyten', 1, 'Ery', 'res', '', '', '', '', 'Erythrozyten', '', '', '', '4.10 - 5.10', 0, 1, ''),
(22, 1, 'Hämoglobin', 1, 'Hglobin', 'res', '', '', '', '', 'Hämoglobin', '', '', 'g_dl', '12.3 - 15.3', 0, 1, ''),
(23, 1, 'Hämatokrit', 1, 'Hkrit', 'res', '', '', '', '', 'Hämatokrit', '', '', 'percent', '35 - 45', 0, 1, ''),
(24, 1, 'MCV', 1, 'MCV', 'res', '', '', '', '', 'MCV', '', '', 'fl', '82 - 101', 0, 1, ''),
(25, 1, 'MCH', 1, 'MCH', 'res', '', '', '', '', 'MCH', '', '', 'pg', '27 - 34', 0, 1, ''),
(26, 1, 'MCHC', 1, 'MCHC', 'res', '', '', '', '', 'MCHC', '', '', 'g_dl', '31.5 - 36', 0, 1, ''),
(27, 1, 'Protein Total', 1, 'ProtTotal', 'res', '', '', '', '', 'Protein Total', '', '', 'g_dl', '6.00 - 8.00', 0, 1, ''),
(28, 1, 'PTT', 1, 'PTT', 'res', '', '', '', '', 'Gerinnung PTT', '', '', 'oth', '26 - 40', 0, 1, ''),
(29, 1, 'Bilirubin', 1, 'Bilir', 'res', '', '', '', '', 'Bilirubin', '', '', 'mg_dl', '0.120 - 1.11', 0, 1, ''),
(30, 1, 'Quick', 1, 'Quick', 'res', '', '', '', '', 'Gerinnung Quick', '', '', 'percent', '70 - 120', 0, 1, ''),
(31, 1, 'Gerinnung INR', 1, 'INR', 'res', '', '', '', '', 'Gerinnung INR', '', '', 'oth', '0.85 - 1.30', 0, 1, ''),
(32, 1, 'Harnstoff', 1, 'Harnst', 'res', '', '', '', '', 'Harnstoff', '', '', 'mg_dl', '10.2 - 49.9', 0, 1, ''),
(33, 1, 'Kreatinin', 1, 'Kreatinin', 'res', '', '', '', '', 'Kreatinin', '', '', 'mg_dl', '0.50 - 0.90', 0, 1, ''),
(34, 1, 'GOT', 1, 'GOT', 'res', '', '', '', '', 'GOT', '', '', 'units_l', '10 - 35', 0, 1, ''),
(35, 1, 'GPT', 1, 'GPT', 'res', '', '', '', '', 'GPT', '', '', 'units_l', '10 -35', 0, 1, ''),
(36, 1, 'Gamma-GT', 1, 'G-GT', 'res', '', '', '', '', 'Gamma-GT', '', '', 'units_l', '< 40', 0, 1, ''),
(37, 1, 'Phosphatase (alk.)', 1, 'alkPhos', 'res', '', '', '', '', 'alk. Phosphatase', '', '', 'units_l', '35 - 104', 0, 1, ''),
(38, 1, 'Lipase', 1, 'Lipase', 'res', '', '', '', '', 'Lipase', '', '', 'units_l', '< 60', 0, 1, ''),
(39, 1, 'CK', 1, 'CK', 'res', '', '', '', '', 'CK', '', '', 'units_l', '< 170', 0, 1, ''),
(40, 1, 'LDH', 1, 'LDH', 'res', '', '', '', '', 'LDH', '', '', 'units_l', '< 250', 0, 1, ''),
(41, 1, 'Kalium', 1, 'Kalium', 'res', '', '', '', '', 'Kalium', '', '', 'hmol_l', '3.6 - 4.8', 0, 1, ''),
(42, 1, 'Natrium', 1, 'Na', 'res', '', '', '', '', 'Natrium', '', '', 'hmol_l', '135 - 144', 0, 1, ''),
(43, 1, 'Calcium', 1, 'Calc', 'res', '', '', '', '', 'Calcium', '', '', 'hmol_l', '2.15 - 2.50', 0, 1, ''),
(44, 1, 'Chlorid', 1, 'Chlorid', 'res', '', '', '', '', 'Chlorid', '', '', 'hmol_l', '98 - 106', 0, 1, ''),
(45, 1, 'C-reakt. Protein', 1, 'crP', 'res', '', '', '', '', 'C-reakt. Protein', '', '', 'mg_dl', '< 0.500', 0, 1, ''),
(46, 1, 'Cholesterin', 1, 'Chol', 'res', '', '', '', '', 'Cholesterin', '', '', '', '< 200', 0, 1, ''),
(47, 1, 'Eisen', 1, 'Fe', 'res', '', '', '', '', 'Eisen', '', '', '', '33 - 193', 0, 1, ''),
(48, 1, 'HBA1c', 1, 'HBA1c', 'res', '', '', '', '', 'HBA1c', '', '', 'percent', '4.0 - 6.0', 0, 1, ''),
(49, 1, 'HBA1Cif', 1, 'HBA1Cif', 'res', '', '', '', '', 'HBA1Cif', '', '', 'oth', '20 - 42', 0, 1, ''),
(50, 1, 'Phosphat Anor', 1, 'PhosAnor', 'res', '', '', '', '', 'Phosphat Anor', '', '', 'hmol_l', '0.87 - 1.45', 0, 1, ''),
(53, 1, 'TPO', 1, 'TPO', 'res', '', '', '', '', 'TPO', '', '', 'oth', '0 - 35', 0, 1, ''),
(54, 1, 'TSH Rezeptor AK', 1, 'TSH-R-AK', 'res', '', '', '', '', 'TSH Rezeptor AK', '', '', 'units_l', '0 - 1.0', 0, 1, ''),
(55, 1, 'ACTH', 1, 'ACTH', 'res', '', '', '', '', 'ACTH', '', '', 'oth', '4.70 - 48.80', 0, 1, ''),
(56, 1, 'Cortisol', 1, 'Cortisol', 'res', '', '', '', '', 'Cortisol', '', '', '', '62.0 - 194.0', 0, 1, ''),
(57, 1, 'GGT', 1, 'GGT', 'res', '', '', '', '', 'GGT', '', '', 'units_l', '< 40', 0, 1, ''),
(58, 1, 'GFR nach MDRD-Formel', 1, 'GFR-MDRD', 'res', '', '', '', '', 'GFR nach MDRD-Formel', '', '', '', '> 80', 0, 1, ''),
(59, 1, 'Harnsäure', 1, 'Harnsäure', 'res', '', '', '', '', 'Harnsäure', '', '', '', '< 6.0', 0, 1, ''),
(60, 1, 'Magnesium', 1, 'Magnesium', 'res', '', '', '', '', 'Magnesium', '', '', 'hmol_l', '0.53 - 1.11', 0, 1, ''),
(61, 1, 'HBE', 1, 'HBE', 'res', '', '', '', '', 'HBE', '', '', 'pg', '27.0 - 34.9', 0, 1, ''),
(62, 0, '24h Urin', 1, '24hUrin', 'ord', '', 'urine', '', '', '24h Urin', '', '', '', '', 0, 1, ''),
(63, 62, 'Ammount', 1, 'Ammount', 'res', '', '', '', '', 'Ammount', '', '', 'ml', '', 0, 1, ''),
(64, 62, 'Natrium', 1, 'Natrium', 'res', '', '', '', '', 'Natrium', '', '', 'mmol/L', '64 - 172', 0, 1, ''),
(65, 62, 'Natrium 24h', 1, 'Natrium24h', 'res', '', '', '', '', 'Natrium 24h', '', '', 'mmol/24h', '40 - 220', 0, 1, '');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
