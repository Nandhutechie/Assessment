package com.novosoft.ProductAssessment.Integration;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import com.novosoft.ProductAssessment.entity.Product;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ProductIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void testCreateAndFetchProduct() {
        // Create a new product
        Product newProduct = new Product(null, "Integration Product", 200.0);
        ResponseEntity<Product> createResponse = restTemplate.postForEntity("/products", newProduct, Product.class);

        assertThat(createResponse.getStatusCodeValue()).isEqualTo(201);
        Product createdProduct = createResponse.getBody();
        assertThat(createdProduct).isNotNull();
        assertThat(createdProduct.getName()).isEqualTo("Integration Product");

        // Fetch the product
        ResponseEntity<Product> getResponse = restTemplate.getForEntity("/products/" + createdProduct.getId(), Product.class);

        assertThat(getResponse.getStatusCodeValue()).isEqualTo(200);
        Product fetchedProduct = getResponse.getBody();
        assertThat(fetchedProduct).isNotNull();
        assertThat(fetchedProduct.getName()).isEqualTo("Integration Product");
    }
}
