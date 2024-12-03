package com.novosoft.ProductAssessment.servicetest;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import static org.junit.jupiter.api.Assertions.*;


import com.novosoft.ProductAssessment.entity.Product;
import com.novosoft.ProductAssessment.repository.ProductRepository;
import com.novosoft.ProductAssessment.service.ProductService;

class ProductServiceTest {

    @InjectMocks
    private ProductService productService;

    @Mock
    private ProductRepository productRepository;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetProductById() {
        Product mockProduct = new Product(1L, "Sample Product", 100.0);
        when(productRepository.findById(1L)).thenReturn(Optional.of(mockProduct));

        Product result = productService.getProductById(1L);

        assertNotNull(result);
        assertEquals("Sample Product", result.getName());
        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    void testSaveProduct() {
        Product newProduct = new Product(null, "New Product", 150.0);
        Product savedProduct = new Product(2L, "New Product", 150.0);

        when(productRepository.save(newProduct)).thenReturn(savedProduct);

        Product result = productService.createProduct(newProduct);

        assertNotNull(result);
        assertEquals(2L, result.getId());
        verify(productRepository, times(1)).save(newProduct);
    }
}
