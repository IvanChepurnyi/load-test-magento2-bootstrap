<?php
/**
 * EcomDev M2 Image Resize fix
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

namespace EcomDev\ImageResizeFix\Model;

class ProductRepository extends \Magento\Catalog\Model\ProductRepository
{
    /**
     * Overridden to reduce memory usage for image resize command
     *
     * @param int $productId
     * @param bool $editMode
     * @param null $storeId
     * @param bool $forceReload
     *
     * @return \Magento\Catalog\Api\Data\ProductInterface|mixed
     * @throws \Magento\Framework\Exception\NoSuchEntityException
     */
    public function getById($productId, $editMode = false, $storeId = null, $forceReload = false)
    {
        $result = parent::getById($productId, $editMode, $storeId, $forceReload);

        // Clean up memory, as we don't want to reference again product on the next resize
        $this->instances = [];
        $this->instancesById = [];

        return $result;
    }

}
