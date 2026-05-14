<?php

/**
 * Bump production-demo tag rows in ip_map_branch.txt.
 *
 * Demo farm rows use either a git branch (branch_tag=branch) or a release tag
 * (branch_tag=tag). The "production" demos pin to a tag like v8_0_0_3. When
 * openemr/openemr cuts a new tag in the same major.minor line, those rows
 * should advance to the new tag; rows on a different major.minor line, or
 * branch-pinned rows, are left alone.
 *
 * Pure: takes file contents in, returns file contents out. Tested directly
 * without filesystem mocking.
 *
 * @package   openemr/demo_farm_openemr
 * @link      https://www.open-emr.org
 * @author    Michael A. Smith <michael@opencoreemr.com>
 * @copyright Copyright (c) 2026 OpenCoreEMR Inc.
 * @license   https://github.com/openemr/demo_farm_openemr/blob/master/LICENSE GNU General Public License 3
 */

declare(strict_types=1);

namespace OpenEMR\DemoFarm;

final readonly class IpMapBumper
{
    // OpenEMR release tags are v<MAJOR>_<MINOR>_<PATCH> (3-part, e.g. v8_1_0)
    // or v<MAJOR>_<MINOR>_<PATCH>_<MICRO> (4-part, e.g. v8_0_0_3 for a patch
    // release of 8.0.0). The bumper only needs MAJOR and MINOR to decide which
    // rows to advance.
    private const TAG_PATTERN = '/^v(\d+)_(\d+)(?:_\d+){1,2}$/';

    public function __construct(
        public string $branchColumn = 'branch',
        public string $branchTagColumn = 'branch_tag',
    ) {
    }

    /**
     * Apply the bump and return [updatedContents, count] where count is the
     * number of rows rewritten. count==0 means nothing matched (no error).
     *
     * @return array{string, int}
     */
    public function bump(string $contents, string $newTag): array
    {
        $newParts = $this->parseTag($newTag);
        if ($newParts === null) {
            throw new \InvalidArgumentException(
                "Invalid OpenEMR release tag: '{$newTag}' "
                . '(expected v<MAJOR>_<MINOR>_<PATCH> or v<MAJOR>_<MINOR>_<PATCH>_<MICRO>)',
            );
        }
        $newMajor = $newParts['major'];
        $newMinor = $newParts['minor'];

        $lines = explode("\n", $contents);
        if (trim($lines[0]) === '') {
            throw new \RuntimeException('ip_map_branch.txt: missing header row');
        }
        $headers = explode("\t", $lines[0]);
        $branchIndex = $this->columnIndex($headers, $this->branchColumn);
        $branchTagIndex = $this->columnIndex($headers, $this->branchTagColumn);

        $rowsRewritten = 0;
        for ($i = 1, $n = count($lines); $i < $n; $i++) {
            $line = $lines[$i];
            if ($line === '' || $line[0] === '#') {
                continue;
            }
            $cells = explode("\t", $line);
            if (!isset($cells[$branchIndex], $cells[$branchTagIndex])) {
                continue;
            }
            if ($cells[$branchTagIndex] !== 'tag') {
                continue;
            }
            $existing = $cells[$branchIndex];
            if ($existing === $newTag) {
                continue;
            }
            $existingParts = $this->parseTag($existing);
            if ($existingParts === null) {
                continue;
            }
            if ($existingParts['major'] !== $newMajor || $existingParts['minor'] !== $newMinor) {
                continue;
            }
            $cells[$branchIndex] = $newTag;
            $lines[$i] = implode("\t", $cells);
            $rowsRewritten++;
        }

        return [implode("\n", $lines), $rowsRewritten];
    }

    /**
     * @param list<string> $headers
     */
    private function columnIndex(array $headers, string $name): int
    {
        $index = array_search($name, $headers, true);
        if ($index === false) {
            throw new \RuntimeException("ip_map_branch.txt: missing required column: {$name}");
        }
        return $index;
    }

    /**
     * @return array{major: string, minor: string}|null
     */
    private function parseTag(string $tag): ?array
    {
        if (preg_match(self::TAG_PATTERN, $tag, $m) !== 1) {
            return null;
        }
        return ['major' => $m[1], 'minor' => $m[2]];
    }
}
