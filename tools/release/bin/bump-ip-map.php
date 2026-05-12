#!/usr/bin/env php
<?php

/**
 * Apply a tag bump to ip_map_branch.txt.
 *
 * Driven by .github/workflows/bump-tag.yml in response to an `openemr-tag`
 * repository_dispatch from openemr/openemr (or workflow_dispatch from a
 * maintainer for manual testing). Idempotent: running twice with the same tag
 * produces zero changes the second time.
 *
 * @package   openemr/demo_farm_openemr
 * @link      https://www.open-emr.org
 * @author    Michael A. Smith <michael@opencoreemr.com>
 * @copyright Copyright (c) 2026 OpenCoreEMR Inc.
 * @license   https://github.com/openemr/demo_farm_openemr/blob/master/LICENSE GNU General Public License 3
 */

declare(strict_types=1);

require dirname(__DIR__) . '/vendor/autoload.php';

use OpenEMR\DemoFarm\IpMapBumper;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\SingleCommandApplication;

(new SingleCommandApplication())
    ->setName('bump-ip-map')
    ->setDescription('Bump production-demo tag rows in ip_map_branch.txt')
    ->addOption('file', null, InputOption::VALUE_REQUIRED, 'Path to ip_map_branch.txt')
    ->addOption('tag', null, InputOption::VALUE_REQUIRED, 'New OpenEMR release tag (e.g. v8_0_0_4)')
    ->addOption('dry-run', null, InputOption::VALUE_NONE, 'Print the would-be change count and exit without writing')
    ->setCode(function (InputInterface $input, OutputInterface $output): int {
        $file = $input->getOption('file');
        $tag = $input->getOption('tag');
        if (!is_string($file) || $file === '') {
            $output->writeln('<error>--file is required</error>');
            return 1;
        }
        if (!is_string($tag) || $tag === '') {
            $output->writeln('<error>--tag is required</error>');
            return 1;
        }
        if (!is_file($file)) {
            $output->writeln("<error>File not found: {$file}</error>");
            return 1;
        }
        $dryRun = (bool) $input->getOption('dry-run');

        $contents = (string) file_get_contents($file);
        try {
            [$updated, $count] = (new IpMapBumper())->bump($contents, $tag);
        } catch (\InvalidArgumentException | \RuntimeException $e) {
            $output->writeln('<error>' . $e->getMessage() . '</error>');
            return 1;
        }

        if ($count === 0) {
            $output->writeln(
                '<info>No rows matched (already on this tag, or no production-tag rows for this minor line).</info>',
            );
            return 0;
        }

        if (!$dryRun) {
            file_put_contents($file, $updated);
        }
        $prefix = $dryRun ? '[dry-run] ' : '';
        $output->writeln("<info>{$prefix}Rewrote {$count} row(s) to {$tag}.</info>");
        return 0;
    })
    ->run();
