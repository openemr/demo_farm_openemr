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
    private const HEADER = "docker_number\topenemr_repo\tbranch\tbranch_tag\tdescription";

    public function testBumpsRowsMatchingMajorMinor(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tProduction\n"
            . "five_a\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tAlt\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(2, $count);
        self::assertStringContainsString("five\thttps://github.com/openemr/openemr.git\tv8_0_0_4\ttag", $updated);
        self::assertStringContainsString("five_a\thttps://github.com/openemr/openemr.git\tv8_0_0_4\ttag", $updated);
        self::assertStringNotContainsString('v8_0_0_3', $updated);
    }

    public function testLeavesBranchPinnedRowsAlone(): void
    {
        $contents = self::HEADER . "\n"
            . "one\thttps://github.com/openemr/openemr.git\tmaster\tbranch\tDev\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(1, $count);
        self::assertStringContainsString("one\thttps://github.com/openemr/openemr.git\tmaster\tbranch", $updated);
        self::assertStringContainsString('v8_0_0_4', $updated);
    }

    public function testLeavesDifferentMajorMinorAlone(): void
    {
        // A v8_1_0_0 dispatch should not bump v8_0_0_3 rows — different minor line.
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tProduction 8.0\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_1_0_0');

        self::assertSame(0, $count);
        self::assertStringContainsString('v8_0_0_3', $updated, 'unrelated tag must remain untouched');
        self::assertStringNotContainsString('v8_1_0_0', $updated);
    }

    public function testIsIdempotent(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_4\ttag\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(0, $count);
        self::assertSame($contents, $updated);
    }

    public function testNoOpWhenNoTagRowsMatch(): void
    {
        // Only branch rows present; the dispatch has no work to do.
        $contents = self::HEADER . "\n"
            . "one\thttps://github.com/openemr/openemr.git\tmaster\tbranch\tDev\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(0, $count);
        self::assertSame($contents, $updated);
    }

    public function testPreservesUnrelatedColumnsAndOtherWhitespace(): void
    {
        $contents = self::HEADER . "\n"
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tDescription with spaces\n"
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
            . "five\thttps://github.com/openemr/openemr.git\tv8_0_0_3\ttag\tProduction\n";

        [$updated, $count] = (new IpMapBumper())->bump($contents, 'v8_0_0_4');

        self::assertSame(1, $count);
        self::assertStringContainsString("short\trepo", $updated, 'short row preserved verbatim');
    }
}
