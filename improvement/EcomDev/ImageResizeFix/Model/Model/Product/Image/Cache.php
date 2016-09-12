<?php
/**
 * magento-benchmark-2
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

namespace EcomDev\ImageResizeFix\Model\Model\Product\Image;


use Magento\Catalog\Helper\Image as ImageHelper;
use Magento\Framework\App\Area;
use Magento\Framework\View\ConfigInterface;
use Magento\Framework\View\DesignInterface;
use Magento\Theme\Model\ResourceModel\Theme\Collection as ThemeCollection;

class Cache extends \Magento\Catalog\Model\Product\Image\Cache
{
    /**
     * Design instance for registering current theme
     *
     * @var DesignInterface
     */
    private $design;

    /**
     * Pass design instance for proper configuration
     *
     * @param ConfigInterface $viewConfig
     * @param ThemeCollection $themeCollection
     * @param ImageHelper $imageHelper
     * @param DesignInterface $design
     */
    public function __construct(
        ConfigInterface $viewConfig,
        ThemeCollection $themeCollection,
        ImageHelper $imageHelper,
        DesignInterface $design
    ) {
        parent::__construct($viewConfig, $themeCollection, $imageHelper);
        $this->design = $design;
    }

    /**
     * Return list of media image attribute variations
     *
     * Fixed with proper design theme setup
     *
     * @return array
     */
    protected function getData()
    {
        if (!$this->data) {
            /** @var \Magento\Theme\Model\Theme $theme */
            foreach ($this->themeCollection->loadRegisteredThemes() as $theme) {
                // Add missing design theme set
                $this->design->setDesignTheme($theme, Area::AREA_FRONTEND);

                $config = $this->viewConfig->getViewConfig([
                    'area' => Area::AREA_FRONTEND,
                    'themeModel' => $theme,
                ]);

                $images = $config->getMediaEntities('Magento_Catalog', ImageHelper::MEDIA_TYPE_CONFIG_NODE);

                foreach ($images as $imageId => $imageData) {
                    $this->data[$theme->getCode() . $imageId] = array_merge(['id' => $imageId], $imageData);
                }
            }
        }

        return $this->data;
    }

}
