package com.novosoft.ProductAssessment.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.novosoft.ProductAssessment.entity.Product;
import com.novosoft.ProductAssessment.service.FetchAndUpdateService;

	


@RestController
@RequestMapping("/api/products")
public class FetchController 
{

	    private final FetchAndUpdateService fetchUpdateService;

	    public FetchController(FetchAndUpdateService fetchUpdateService) {
	        this.fetchUpdateService = fetchUpdateService;
	    }

	    @GetMapping("/fetch")
	    public ResponseEntity<List<Product>> fetchProduct() {
	    	
	        List<Product> products = fetchUpdateService.fetchExternalProducts();
	        
	        return ResponseEntity.ok(products);
	    }

//	    @PutMapping("/{id}")
//	    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product updatedProduct) {
//	        Product product = fetchUpdateService.updateProductPrices(id, updatedProduct);
//	        return ResponseEntity.ok(product);
//	    }
	}

