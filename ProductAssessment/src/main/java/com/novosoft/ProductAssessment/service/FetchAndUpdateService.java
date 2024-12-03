package com.novosoft.ProductAssessment.service;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.novosoft.ProductAssessment.entity.Product;
import com.novosoft.ProductAssessment.repository.ProductRepository;


@Service
public class FetchAndUpdateService {
	
	private final ProductRepository productRepository;
    private final RestTemplate restTemplate;

    public FetchAndUpdateService(ProductRepository productRepository, RestTemplate restTemplate) {
        this.productRepository = productRepository;
        this.restTemplate = restTemplate;
    }

    @Cacheable("products")
    public List<Product> fetchExternalProducts() {
        String url = "https://fakestoreapi.com/products";
        Product[] externalProducts = restTemplate.getForObject(url, Product[].class);
        return List.of(externalProducts);
    }

    public void updateProductPrices() {
        List<Product> externalProducts = fetchExternalProducts();
        externalProducts.forEach(product -> {
            productRepository.findById(product.getId())
                .ifPresent(existingProduct -> {
                    existingProduct.setPrice(product.getPrice());
                    productRepository.save(existingProduct);
                });
        });
    }
}

