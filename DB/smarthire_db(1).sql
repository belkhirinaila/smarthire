-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Client :  127.0.0.1
-- Généré le :  Mar 12 Mai 2026 à 17:32
-- Version du serveur :  5.6.17
-- Version de PHP :  5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données :  `smarthire_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `access_requests`
--

CREATE TABLE IF NOT EXISTS `access_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recruiter_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `recruiter_id` (`recruiter_id`,`candidate_id`),
  KEY `candidate_id` (`candidate_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `access_requests`
--

INSERT INTO `access_requests` (`id`, `recruiter_id`, `candidate_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 22, 21, 'pending', '2026-05-07 15:41:58', '2026-05-07 15:41:58');

-- --------------------------------------------------------

--
-- Structure de la table `applications`
--

CREATE TABLE IF NOT EXISTS `applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `score` decimal(5,2) DEFAULT NULL,
  `cv_file_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

--
-- Contenu de la table `applications`
--

INSERT INTO `applications` (`id`, `job_id`, `candidate_id`, `status`, `score`, `cv_file_id`, `created_at`, `updated_at`) VALUES
(1, 1, 2, '', NULL, NULL, '2026-03-12 16:18:44', '2026-04-07 21:23:19'),
(2, 1, 1, '', NULL, NULL, '2026-03-24 16:46:00', '2026-04-07 21:23:19'),
(3, 1, 1, '', NULL, NULL, '2026-04-01 14:14:57', '2026-04-07 21:23:19'),
(4, 1, 21, 'pending', NULL, NULL, '2026-04-14 09:36:44', '2026-04-14 09:36:44'),
(5, 8, 21, 'pending', '5.00', NULL, '2026-04-16 20:58:06', '2026-05-06 09:33:02'),
(6, 3, 21, 'pending', '35.00', NULL, '2026-04-16 21:02:35', '2026-05-06 17:38:22'),
(7, 3, 1, 'pending', '65.00', NULL, '2026-04-17 19:47:48', '2026-05-06 17:38:22'),
(8, 3, 1, 'pending', '65.00', NULL, '2026-04-17 19:47:56', '2026-05-06 17:38:22'),
(9, 9, 21, 'pending', '55.00', NULL, '2026-04-17 19:56:44', '2026-05-12 06:40:44'),
(10, 8, 21, 'pending', '5.00', NULL, '2026-04-28 22:24:16', '2026-05-06 09:33:01'),
(11, 12, 21, 'pending', '35.00', NULL, '2026-05-06 18:31:48', '2026-05-06 18:32:37');

-- --------------------------------------------------------

--
-- Structure de la table `application_notes`
--

CREATE TABLE IF NOT EXISTS `application_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) NOT NULL,
  `recruiter_id` int(11) NOT NULL,
  `note` text NOT NULL,
  `rating` decimal(2,1) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_application_notes_application` (`application_id`),
  KEY `fk_application_notes_recruiter` (`recruiter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `candidate_profiles`
--

CREATE TABLE IF NOT EXISTS `candidate_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `professional_headline` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `bio` text,
  `github_link` varchar(255) DEFAULT NULL,
  `behance_link` varchar(255) DEFAULT NULL,
  `personal_website` varchar(255) DEFAULT NULL,
  `profile_photo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_public` tinyint(1) DEFAULT '1',
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `cv_generated` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `phone_number` (`phone_number`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `candidate_profiles`
--

INSERT INTO `candidate_profiles` (`id`, `user_id`, `professional_headline`, `location`, `bio`, `github_link`, `behance_link`, `personal_website`, `profile_photo`, `created_at`, `updated_at`, `is_public`, `phone_number`, `email`, `cv_generated`) VALUES
(1, 1, 'Senior UI/UX Designer', 'France Marseille', '5 years expériences', 'https://github.com/new', 'https://behance.net/new', 'https://newportfolio.com', 'newphoto.jpg', '2026-03-24 19:44:12', '2026-04-08 19:26:45', 1, NULL, NULL, NULL),
(2, 21, 'flutter', 'alger', 'naila', '', '', '', 'uploads\\profile\\1778548825022.jpg', '2026-04-14 12:58:31', '2026-05-12 06:05:57', 1, '0775278416', 'nailabelkhiri23@gmail.com', '/uploads/cv_21.pdf');

-- --------------------------------------------------------

--
-- Structure de la table `company_profiles`
--

CREATE TABLE IF NOT EXISTS `company_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `description` text,
  `logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `cover_image` varchar(255) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `company_size` varchar(50) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `is_blocked` tinyint(4) DEFAULT '0',
  `registre_commerce` varchar(255) DEFAULT NULL,
  `nif_nis` varchar(255) DEFAULT NULL,
  `carte_fiscale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `company_profiles`
--

INSERT INTO `company_profiles` (`id`, `user_id`, `name`, `industry`, `website`, `description`, `logo`, `created_at`, `cover_image`, `location`, `company_size`, `status`, `is_blocked`, `registre_commerce`, `nif_nis`, `carte_fiscale`) VALUES
(1, 22, 'sntfff', 'Information Technology', '', 'jdidbddk', 'uploads\\company\\1778545454823.jpg', '2026-04-15 22:30:42', 'uploads\\company\\1778545455161.jpg', 'Sétif', '0', 'approved', 0, 'uploads\\company\\1778550670828.pdf', 'uploads\\company\\1778550670879.pdf', 'uploads\\company\\1778550670967'),
(2, 24, 'walid', 'Information Technology', '', '', 'uploads\\company\\1778553980434.jpg', '2026-05-12 02:46:20', 'uploads\\company\\1778553980577.jpg', 'Alger', '0', 'pending', 0, 'uploads\\company\\1778553980814.pdf', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `company_users`
--

CREATE TABLE IF NOT EXISTS `company_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'recruiter',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `company_verifications`
--

CREATE TABLE IF NOT EXISTS `company_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `document` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `conversations`
--

CREATE TABLE IF NOT EXISTS `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `candidate_id` int(11) NOT NULL,
  `recruiter_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `conversations`
--

INSERT INTO `conversations` (`id`, `candidate_id`, `recruiter_id`, `created_at`) VALUES
(1, 21, 22, '2026-04-17 18:08:03'),
(2, 1, 22, '2026-04-17 20:58:15');

-- --------------------------------------------------------

--
-- Structure de la table `cv_visibility`
--

CREATE TABLE IF NOT EXISTS `cv_visibility` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `visibility` enum('public','private','selective') DEFAULT 'public',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `cv_visibility`
--

INSERT INTO `cv_visibility` (`id`, `user_id`, `visibility`, `created_at`, `updated_at`) VALUES
(1, 1, 'private', '2026-03-25 16:22:18', '2026-04-02 19:49:28'),
(2, 21, 'public', '2026-04-17 16:10:39', '2026-05-12 06:05:57');

-- --------------------------------------------------------

--
-- Structure de la table `education`
--

CREATE TABLE IF NOT EXISTS `education` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `school` varchar(255) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Contenu de la table `education`
--

INSERT INTO `education` (`id`, `user_id`, `school`, `degree`, `field`, `start_date`, `end_date`, `created_at`) VALUES
(1, 1, 'USTHB a', 'Master a', 'Informatique a', '2019-12-07', '2021-12-30', '2026-03-24 21:43:27'),
(2, 1, 'a', 'a', 'a', '2026-04-02', '2026-04-30', '2026-04-02 16:24:00'),
(3, 21, 'fac centrale', '15', '', '2025-05-06', '0000-00-00', '2026-04-17 17:40:33');

-- --------------------------------------------------------

--
-- Structure de la table `experiences`
--

CREATE TABLE IF NOT EXISTS `experiences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Contenu de la table `experiences`
--

INSERT INTO `experiences` (`id`, `user_id`, `job_title`, `company`, `start_date`, `end_date`, `description`, `created_at`) VALUES
(1, 1, 'Frontend Developer', 'Tech DZ', '2026-04-02', '2023-12-30', 'Worked on React applicationssss', '2026-03-24 21:31:52'),
(3, 21, 'software engineer', 'air Algérie', '2025-10-02', '2026-04-01', '', '2026-04-17 17:39:52');

-- --------------------------------------------------------

--
-- Structure de la table `favorite_applicants`
--

CREATE TABLE IF NOT EXISTS `favorite_applicants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recruiter_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_favorite` (`recruiter_id`,`candidate_id`,`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `jobs`
--

CREATE TABLE IF NOT EXISTS `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `salary` varchar(100) DEFAULT NULL,
  `salary_min` decimal(10,2) DEFAULT NULL,
  `salary_max` decimal(10,2) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `recruiter_id` int(11) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `work_mode` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `status` enum('draft','active','closed') NOT NULL DEFAULT 'active',
  `views_count` int(11) NOT NULL DEFAULT '0',
  `applicants_count` int(11) NOT NULL DEFAULT '0',
  `published_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `closed_at` timestamp NULL DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `is_blocked` tinyint(1) DEFAULT '0',
  `requirements` text,
  `experience` text,
  `education` text,
  `languages` text,
  `team` text,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=17 ;

--
-- Contenu de la table `jobs`
--

INSERT INTO `jobs` (`id`, `title`, `description`, `location`, `salary`, `salary_min`, `salary_max`, `company_name`, `created_by`, `created_at`, `recruiter_id`, `type`, `work_mode`, `category`, `status`, `views_count`, `applicants_count`, `published_at`, `closed_at`, `company_id`, `is_blocked`, `requirements`, `experience`, `education`, `languages`, `team`) VALUES
(1, 'Backend Developer', 'Node.js + MySQL + JWT', 'Algiers', '200k - 300k DZD', NULL, NULL, 'SmartHire DZ', NULL, '2026-03-11 17:22:55', 2, NULL, NULL, NULL, 'active', 0, 0, '2026-04-07 21:22:11', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(2, 'Web developer ', 'bdkdbdkdsbsjsnj', '06 - Béjaïa', NULL, NULL, NULL, NULL, 22, '2026-04-15 23:42:02', NULL, 'Part-time', 'Onsite', NULL, 'active', 0, 0, '2026-04-15 23:42:02', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(3, 'software engineer ', 'travail bien et professionnel ', '21 - Skikda', NULL, NULL, NULL, NULL, 22, '2026-04-15 23:43:05', NULL, 'Part-time', 'Onsite', NULL, 'closed', 0, 0, '2026-04-15 23:43:05', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(8, 'ingénieur ', 'naila naila', 'oran', NULL, '10009.00', '10000000.00', NULL, 22, '2026-04-16 17:08:09', NULL, 'Full-time', 'Remote', 'IT', 'draft', 0, 0, '2026-04-16 17:08:09', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(9, 'cyber security ', 'profesyonel job', 'Blida ', NULL, '100.00', '10000000.00', NULL, 22, '2026-04-17 19:55:15', NULL, 'Internship', 'Remote', 'Finance', 'active', 0, 0, '2026-04-17 19:55:15', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(10, 'web developer ', 'bdkdbdkdbsksbsb', 'Algiers ', NULL, '1000.00', '10000000.00', NULL, 22, '2026-04-30 20:11:08', NULL, 'Part-time', 'On-site', 'Marketing', 'active', 0, 0, '2026-04-30 20:11:08', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(12, 'Node.js Backend Developer ', 'We are looking for a skilled Backend Developer to build scalable REST APIs, manage databases, and collaborate with frontend and DevOps teams in a fast-growing tech environment.', 'Oran ', NULL, '10000.00', '99999999.99', NULL, 22, '2026-05-06 18:30:28', NULL, 'Full-time', 'Remote', 'IT', 'active', 0, 0, '2026-05-06 18:30:28', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL),
(13, 'digital marketing spécialiste ', 'We are looking for a creative and motivated Digital Marketing Specialist to manage social media campaigns, improve brand visibility, and analyze marketing performance across different digital platforms.', 'Oran', NULL, '1000.00', '900000.00', NULL, 22, '2026-05-07 09:40:12', NULL, 'Full-time', 'On-site', 'IT', 'active', 0, 0, '2026-05-07 09:40:12', NULL, 1, 0, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `job_skills`
--

CREATE TABLE IF NOT EXISTS `job_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_job_skills_job` (`job_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=17 ;

--
-- Contenu de la table `job_skills`
--

INSERT INTO `job_skills` (`id`, `job_id`, `skill_name`, `created_at`) VALUES
(2, 9, 'flutter', '2026-04-17 19:55:15'),
(3, 9, 'dart', '2026-04-17 19:55:15'),
(4, 9, 'node.js', '2026-04-17 19:55:15'),
(5, 9, 'HTML', '2026-04-17 19:55:15'),
(6, 9, 'css', '2026-04-17 19:55:15'),
(7, 10, 'html', '2026-04-30 20:11:08'),
(8, 10, 'css', '2026-04-30 20:11:08'),
(9, 12, 'node.js', '2026-05-06 18:30:28'),
(10, 12, 'MySQL', '2026-05-06 18:30:28'),
(11, 12, 'Git', '2026-05-06 18:30:28'),
(12, 13, 'content creator', '2026-05-07 09:40:12');

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `receiver_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `conversation_id` (`conversation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=25 ;

--
-- Contenu de la table `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `message`, `created_at`, `receiver_id`, `is_read`) VALUES
(1, 1, 22, 'test message', '2026-04-17 18:36:59', NULL, 0),
(2, 1, 22, 'coucou coucou ', '2026-04-17 18:40:05', NULL, 0),
(3, 1, 22, 'ça fait plaisir ', '2026-04-17 18:40:14', NULL, 0),
(20, 2, 22, 'salut salut ', '2026-04-17 20:58:21', NULL, 0),
(21, 1, 21, 'salam', '2026-05-12 04:52:33', NULL, 0),
(22, 1, 22, 'hello', '2026-05-12 04:59:59', NULL, 0),
(23, 1, 21, 'coucou', '2026-05-12 06:03:01', NULL, 0),
(24, 1, 21, 'salut salut', '2026-05-12 06:10:03', 22, 0);

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50) DEFAULT 'general',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `created_at`) VALUES
(1, 21, 'New recruiter request', 'A recruiter sent you a request.', 'request', 1, '2026-05-07 15:41:58');

-- --------------------------------------------------------

--
-- Structure de la table `pending_users`
--

CREATE TABLE IF NOT EXISTS `pending_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL,
  `otp_code` varchar(10) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Structure de la table `portfolio_links`
--

CREATE TABLE IF NOT EXISTS `portfolio_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `portfolio_links`
--

INSERT INTO `portfolio_links` (`id`, `user_id`, `title`, `url`, `created_at`) VALUES
(1, 1, 'Mon Portfolio', 'https://myportfolio.com', '2026-03-25 16:58:38');

-- --------------------------------------------------------

--
-- Structure de la table `profile_access_requests`
--

CREATE TABLE IF NOT EXISTS `profile_access_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recruiter_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `status` enum('pending','approved','declined') DEFAULT 'pending',
  `message` text,
  `responded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_profile_access_recruiter` (`recruiter_id`),
  KEY `fk_profile_access_candidate` (`candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `saved_jobs`
--

CREATE TABLE IF NOT EXISTS `saved_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`job_id`),
  KEY `job_id` (`job_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

--
-- Contenu de la table `saved_jobs`
--

INSERT INTO `saved_jobs` (`id`, `user_id`, `job_id`, `created_at`) VALUES
(4, 1, 1, '2026-04-08 19:25:45'),
(8, 21, 2, '2026-04-15 23:56:45'),
(10, 21, 8, '2026-04-28 22:24:12');

-- --------------------------------------------------------

--
-- Structure de la table `skills`
--

CREATE TABLE IF NOT EXISTS `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `skill_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Contenu de la table `skills`
--

INSERT INTO `skills` (`id`, `user_id`, `skill_name`, `created_at`) VALUES
(4, 1, 'C++', '2026-04-01 22:24:31'),
(5, 1, 'java script', '2026-04-01 22:34:42'),
(6, 1, 'node js', '2026-04-02 15:19:44'),
(7, 21, 'flutter', '2026-04-14 15:03:22');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('candidate','recruiter','admin') NOT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `otp_code` varchar(10) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `reset_otp_code` varchar(10) DEFAULT NULL,
  `reset_otp_expires_at` datetime DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `is_blocked` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=25 ;

--
-- Contenu de la table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `role`, `is_verified`, `created_at`, `otp_code`, `otp_expires_at`, `reset_otp_code`, `reset_otp_expires_at`, `phone`, `is_blocked`) VALUES
(1, 'Test User', 'test1@gmail.com', '$2b$10$4bGKuvb9sDIqQq9ycXwyOeZtkrKr9b5Y9R4arsshPCerQAKXscCeK', 'candidate', 0, '2026-03-03 00:42:06', NULL, NULL, NULL, NULL, NULL, 0),
(2, 'Recruiter One', 'recruiter1@gmail.com', '$2b$10$AR54NOA0WWSNe8rKR6OAseHyEopckJjubUYW/2XP01fuHA6jK4SOq', 'recruiter', 0, '2026-03-03 01:21:15', NULL, NULL, NULL, NULL, NULL, 0),
(21, 'Naila Belkhiri', 'nailabelkhiri23@gmail.com', '$2b$10$PTVW8sRwOYeJDxbeDCSQB.5UdUPa1JpD/EG3ttOgYTFNmZVzqMuEu', 'candidate', 1, '2026-04-14 09:02:02', NULL, NULL, NULL, NULL, NULL, 0),
(22, 'aya belkhiri', 'belkhirinaila09@gmail.com', '$2b$10$Zf88jMhEJWpLieZYIgMCEuuQD/BszJ1lBfDBQlj1rPIppZa5oZ8jy', 'recruiter', 1, '2026-04-14 21:15:38', NULL, NULL, '8139', '2026-05-11 23:49:36', NULL, 0),
(23, 'Admin', 'admin@smarthire.com', '$2b$10$AGUwlC2Mgoem0F1t3juWw.TaJFaNX5QoKCIhNu46bbuVK/7QG0xSG', 'admin', 0, '2026-04-22 13:46:50', NULL, NULL, NULL, NULL, NULL, 0),
(24, 'walid belkhiri', 'ull441499@gmail.com', '$2b$10$71IvXVwMZe1yW1HeJbLbPOw1.jbiYEEBOgtcQbdz.wsUHxT42iF/e', 'recruiter', 1, '2026-05-12 02:21:00', NULL, NULL, NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Structure de la table `user_settings`
--

CREATE TABLE IF NOT EXISTS `user_settings` (
  `user_id` int(11) NOT NULL,
  `notifications_enabled` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `access_requests`
--
ALTER TABLE `access_requests`
  ADD CONSTRAINT `access_requests_ibfk_1` FOREIGN KEY (`recruiter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `access_requests_ibfk_2` FOREIGN KEY (`candidate_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `application_notes`
--
ALTER TABLE `application_notes`
  ADD CONSTRAINT `fk_application_notes_application` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_application_notes_recruiter` FOREIGN KEY (`recruiter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidate_profiles`
--
ALTER TABLE `candidate_profiles`
  ADD CONSTRAINT `candidate_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cv_visibility`
--
ALTER TABLE `cv_visibility`
  ADD CONSTRAINT `cv_visibility_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `education`
--
ALTER TABLE `education`
  ADD CONSTRAINT `education_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `experiences`
--
ALTER TABLE `experiences`
  ADD CONSTRAINT `experiences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `jobs`
--
ALTER TABLE `jobs`
  ADD CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `job_skills`
--
ALTER TABLE `job_skills`
  ADD CONSTRAINT `fk_job_skills_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `portfolio_links`
--
ALTER TABLE `portfolio_links`
  ADD CONSTRAINT `portfolio_links_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `profile_access_requests`
--
ALTER TABLE `profile_access_requests`
  ADD CONSTRAINT `fk_profile_access_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_profile_access_recruiter` FOREIGN KEY (`recruiter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `saved_jobs`
--
ALTER TABLE `saved_jobs`
  ADD CONSTRAINT `saved_jobs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `saved_jobs_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `skills`
--
ALTER TABLE `skills`
  ADD CONSTRAINT `skills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
