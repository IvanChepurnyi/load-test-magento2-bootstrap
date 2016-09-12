<?php
/**
 * EcomDev M2 Varnish Cache Fix
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Open Software License (OSL 3.0)
 * that is bundled with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/osl-3.0.php
 *
 * @copyright  Copyright (c) 2016 EcomDev BV (http://www.ecomdev.org)
 * @license    https://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
 * @author     Ivan Chepurnyi <ivan@ecomdev.org>
 */

namespace EcomDev\PageCacheFix\Model\Observer;


class ProcessLayoutRenderElement extends \Magento\PageCache\Observer\ProcessLayoutRenderElement
{
    /**
     * Ignored layout handle patterns for ESI include
     *
     * @var string[]
     */
    private $ignoredHandlePatterns;

    /**
     * Add ignored handle patterns to request
     *
     * @param \Magento\PageCache\Model\Config $config
     * @param string[] $ignoredHandlePatterns
     */
    public function __construct(\Magento\PageCache\Model\Config $config, array $ignoredHandlePatterns = [])
    {
        parent::__construct($config);
        $this->ignoredHandlePatterns = $ignoredHandlePatterns;
    }

    /**
     * Replaces output of block with ESI tag + filters layout handles passed to esi controller
     *
     * @param \Magento\Framework\View\Element\AbstractBlock $block
     * @param \Magento\Framework\View\Layout $layout
     *
     * @return string
     */
    protected function _wrapEsi(
        \Magento\Framework\View\Element\AbstractBlock $block,
        \Magento\Framework\View\Layout $layout
    ) {
        $url = $block->getUrl(
            'page_cache/block/esi',
            [
                'blocks' => json_encode([$block->getNameInLayout()]),
                'handles' => json_encode($this->filterLayoutHanldes($layout->getUpdate()->getHandles()))
            ]
        );
        return sprintf('<esi:include src="%s" />', $url);
    }

    /**
     * Filters layout handles for ESI include by using ignored pattern matching
     *
     * @param string[] $layoutHandles
     * @return string[]
     */
    private function filterLayoutHanldes($layoutHandles)
    {
        foreach ($this->ignoredHandlePatterns as $pattern) {
            $layoutHandles = array_filter($layoutHandles, function ($handle) use ($pattern) {
                return preg_match($pattern, $handle) === 0;
            });
        }

        return $layoutHandles;
    }


}
