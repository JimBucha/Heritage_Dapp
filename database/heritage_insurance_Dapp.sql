-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 12, 2025 at 11:28 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `heritage_insurance_Dapp`
--

-- --------------------------------------------------------

--
-- Table structure for table `claims`
--

CREATE TABLE `claims` (
  `claim_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `ipfs_evidence` varchar(255) DEFAULT NULL COMMENT 'IPFS CID for claim documents',
  `amount_claimed` decimal(18,2) DEFAULT NULL,
  `blockchain_tx_hash` varchar(255) DEFAULT NULL COMMENT 'On-chain payout transaction',
  `reviewed_by` int(11) DEFAULT NULL COMMENT 'Claims Manager',
  `review_comments` text DEFAULT NULL COMMENT 'Optional review comments',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faqs_forms`
--

CREATE TABLE `faqs_forms` (
  `faq_form_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `ipfs_hash` varchar(255) DEFAULT NULL,
  `version` varchar(20) NOT NULL COMMENT 'e.g., v1.2',
  `is_current` tinyint(1) DEFAULT 1,
  `linked_policy_id` int(11) DEFAULT NULL,
  `linked_inventory_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `item_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'e.g., Telematics Device, FAQ PDF',
  `type` enum('physical','digital') NOT NULL,
  `description` text DEFAULT NULL,
  `quantity` int(11) DEFAULT 1 COMMENT 'For physical items',
  `ipfs_hash` varchar(255) DEFAULT NULL COMMENT 'For digital items',
  `linked_policy_id` int(11) DEFAULT NULL COMMENT 'Linked policy (e.g., motor insurance requiring a device)',
  `auto_assign` tinyint(1) DEFAULT 0 COMMENT 'Auto-assign on policy purchase',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `policies`
--

CREATE TABLE `policies` (
  `policy_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'e.g., Boresha Maisha Pension',
  `category_id` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `ipfs_hash` varchar(255) DEFAULT NULL COMMENT 'IPFS CID for policy PDF/terms',
  `required_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'e.g., ["ID", "KRA Pin", "Equipment Installation Certificate"]' CHECK (json_valid(`required_documents`)),
  `requires_equipment` tinyint(1) DEFAULT 0 COMMENT 'True if this policy requires specific equipment',
  `equipment_details` text DEFAULT NULL COMMENT 'Optional: equipment specifications',
  `nft_contract_address` varchar(255) DEFAULT NULL COMMENT 'Blockchain address for minted NFT',
  `created_by` int(11) NOT NULL COMMENT 'Underwriting Manager',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `policy_categories`
--

CREATE TABLE `policy_categories` (
  `category_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'e.g., Pension, Motor, Health',
  `audience` enum('personal','corporate') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `report_id` int(11) NOT NULL,
  `type` enum('claims_summary','financial','inventory') NOT NULL,
  `generated_by` int(11) NOT NULL COMMENT 'Admin/Finance Officer',
  `date_range_start` date DEFAULT NULL,
  `date_range_end` date DEFAULT NULL,
  `data_source` enum('blockchain','database','both') DEFAULT 'both',
  `generated_pdf_hash` varchar(255) DEFAULT NULL COMMENT 'IPFS CID for PDF',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `tx_id` int(11) NOT NULL,
  `user_policy_id` int(11) NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `blockchain_tx_hash` varchar(255) NOT NULL COMMENT 'On-chain proof',
  `processed_by` int(11) DEFAULT NULL COMMENT 'Finance Officer',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `wallet_address` varchar(255) DEFAULT NULL COMMENT 'Wallet for policyholders',
  `role` enum('admin','claims_manager','underwriting_manager','policy_manager','finance_officer','intermediary','customer_service','policyholder') NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('pending','approved','denied','suspended') DEFAULT 'pending',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft delete timestamp',
  `action_by` int(11) DEFAULT NULL COMMENT 'Admin who approved/denied',
  `action_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_policies`
--

CREATE TABLE `user_policies` (
  `user_policy_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `purchase_date` date NOT NULL,
  `status` enum('active','expired','canceled') DEFAULT 'active',
  `payment_status` enum('paid','unpaid','pending') DEFAULT 'unpaid',
  `linked_inventory_id` int(11) DEFAULT NULL COMMENT 'e.g., Assigned telematics device',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `claims`
--
ALTER TABLE `claims`
  ADD PRIMARY KEY (`claim_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `policy_id` (`policy_id`),
  ADD KEY `reviewed_by` (`reviewed_by`);

--
-- Indexes for table `faqs_forms`
--
ALTER TABLE `faqs_forms`
  ADD PRIMARY KEY (`faq_form_id`),
  ADD KEY `linked_policy_id` (`linked_policy_id`),
  ADD KEY `linked_inventory_id` (`linked_inventory_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `linked_policy_id` (`linked_policy_id`);

--
-- Indexes for table `policies`
--
ALTER TABLE `policies`
  ADD PRIMARY KEY (`policy_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `policy_categories`
--
ALTER TABLE `policy_categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `generated_by` (`generated_by`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`tx_id`),
  ADD KEY `user_policy_id` (`user_policy_id`),
  ADD KEY `processed_by` (`processed_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `wallet_address` (`wallet_address`),
  ADD KEY `action_by` (`action_by`),
  ADD KEY `idx_users_status` (`status`),
  ADD KEY `idx_users_role` (`role`);

--
-- Indexes for table `user_policies`
--
ALTER TABLE `user_policies`
  ADD PRIMARY KEY (`user_policy_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `policy_id` (`policy_id`),
  ADD KEY `linked_inventory_id` (`linked_inventory_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `claims`
--
ALTER TABLE `claims`
  MODIFY `claim_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faqs_forms`
--
ALTER TABLE `faqs_forms`
  MODIFY `faq_form_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `policies`
--
ALTER TABLE `policies`
  MODIFY `policy_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `policy_categories`
--
ALTER TABLE `policy_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `tx_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_policies`
--
ALTER TABLE `user_policies`
  MODIFY `user_policy_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `claims`
--
ALTER TABLE `claims`
  ADD CONSTRAINT `claims_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `claims_ibfk_2` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`policy_id`),
  ADD CONSTRAINT `claims_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `faqs_forms`
--
ALTER TABLE `faqs_forms`
  ADD CONSTRAINT `faqs_forms_ibfk_1` FOREIGN KEY (`linked_policy_id`) REFERENCES `policies` (`policy_id`),
  ADD CONSTRAINT `faqs_forms_ibfk_2` FOREIGN KEY (`linked_inventory_id`) REFERENCES `inventory` (`item_id`);

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`linked_policy_id`) REFERENCES `policies` (`policy_id`);

--
-- Constraints for table `policies`
--
ALTER TABLE `policies`
  ADD CONSTRAINT `policies_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `policy_categories` (`category_id`),
  ADD CONSTRAINT `policies_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_policy_id`) REFERENCES `user_policies` (`user_policy_id`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`action_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `user_policies`
--
ALTER TABLE `user_policies`
  ADD CONSTRAINT `user_policies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `user_policies_ibfk_2` FOREIGN KEY (`policy_id`) REFERENCES `policies` (`policy_id`),
  ADD CONSTRAINT `user_policies_ibfk_3` FOREIGN KEY (`linked_inventory_id`) REFERENCES `inventory` (`item_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
