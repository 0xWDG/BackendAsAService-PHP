<?php

use PHPUnit\Framework\TestCase;

final class Test extends TestCase
{
    public function setUp()
    {
        echo sprintf("%s^ Tested '%s'.%s", PHP_EOL, $this->getName(), PHP_EOL);
    }
    public function testWillAlwaysPass()
    {
        $this->assertEquals(
            'a',
            'a'
        );
    }
}
