<?php

/**
 * @package   openemr/demo_farm_openemr
 * @link      https://www.open-emr.org
 * @author    Michael A. Smith <michael@opencoreemr.com>
 * @copyright Copyright (c) 2026 OpenCoreEMR Inc.
 * @license   https://github.com/openemr/demo_farm_openemr/blob/master/LICENSE GNU General Public License 3
 */

declare(strict_types=1);

namespace OpenEMR\DemoFarm\Tests;

use OpenEMR\DemoFarm\IpMapBumper;
use PHPUnit\Framework\TestCase;

final class IpMapBumperTest extends TestCase
{
    // Header reflects the live ip_map_branch.txt schema after the branch_tag
    // deprecation: col 3 is "branch", col 4 keeps the legacy position labeled
    // "branch_tag(not used)" with all values normalized to "0".
    private const HEADER = "docker_number\topenemr_repo\tbranch\tbranch_tag(not used)\tdescription";

    public function testBumpsRowsMatchingMajorMinor(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tProduction\n"
            . "five_a\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tAlt\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(2, $count);
        self::assertStringContainsString("five\thttps://github.com/openemr/openemr.git\tv8_0_0_4\t0", $updated);
        self::assertStringContainsString("five_a\thttps://github.com/openemr/openemr.git\tv8_0_0_4\t0", $updated);
        self::assertStringNotContainsString('v8_0_0_3', $updated);
    }

    public function testLeavesBranchPinnedRowsAlone(): void
    {
        // Branch rows (col 3 = "master", "rel-810", etc.) are identified
        // purely by the regex on the branch column -- they don't match the
        // tag pattern, so they're skipped.
        $contents = self::HEADER . "\n"
            . "one\thttps://github.com/openemr/openemr.git\tmaster\t0\tDev\n"
            . "eight\thttps://github.com/openemr/openemr.git\trel-810\t0\tRel 8.1\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(1, $count);
        self::assertStringContainsString("one\thttps://github.com/openemr/openemr.git\tmaster\t0", $updated);
        self::assertStringContainsString("eight\thttps://github.com/openemr/openemr.git\trel-810\t0", $updated);
        self::assertStringContainsString('v8_0_0_4', $updated);
    }

    public function testLeavesDifferentMajorMinorAlone(): void
    {
        // A v8_1_0_0 dispatch should not bump v8_0_0_3 rows — different minor line.
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tProduction 8.0\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_1_0_0');

        self::assertSame(0, $count);
        self::assertStringContainsString('v8_0_0_3', $updated, 'unrelated tag must remain untouched');
        self::assertStringNotContainsString('v8_1_0_0', $updated);
    }

    public function testIsIdempotent(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_4\t0\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(0, $count);
        self::assertSame($contents, $updated);
    }

    public function testNoOpWhenNoTagRowsMatch(): void
    {
        // Only branch rows present; the dispatch has no work to do.
        $contents = self::HEADER . "\n"
            . "one\thttps://github.com/openemr/openemr.git\tmaster\t0\tDev\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(0, $count);
        self::assertSame($contents, $updated);
    }

    public function testPreservesUnrelatedColumnsAndOtherWhitespace(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tDescription with spaces\n"
            . "\n"
            . "# comment line should be skipped\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(1, $count);
        self::assertStringContainsString('Description with spaces', $updated);
        self::assertStringContainsString("\n\n", $updated, 'blank line preserved');
        self::assertStringContainsString('# comment line should be skipped', $updated);
    }

    public function testRejectsMalformedNewTag(): void
    {
        $bumper = new IpMapBumper();

        $this->expectException(\InvalidArgumentException::class);
        $bumper->bump(self::HEADER . "\n", 'rel-810');
    }

    public function testThrowsWhenHeaderMissing(): void
    {
        $bumper = new IpMapBumper();

        $this->expectException(\RuntimeException::class);
        $bumper->bump('', 'v8_0_0_4');
    }

    public function testThrowsWhenColumnMissing(): void
    {
        $contents = "docker_number\topenemr_repo\n"
            . "five\thttps://github.com/openemr/openemr.git\n";
        $bumper = new IpMapBumper();

        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('missing required column: branch');
        $bumper->bump($contents, 'v8_0_0_4');
    }

    public function testRowMissingExpectedColumnsIsSkipped(): void
    {
        // A short row (e.g. trailing-tab loss) shouldn't crash the bumper.
        $contents = self::HEADER . "\n"
            . "short\trepo\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\t0\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(1, $count);
        self::assertStringContainsString("short\trepo", $updated, 'short row preserved verbatim');
    }
}
