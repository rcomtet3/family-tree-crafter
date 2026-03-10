package com.familytree.person;

import com.familytree.person.model.Gender;
import com.familytree.person.model.Person;
import com.familytree.person.repository.PersonRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class PersonControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PersonRepository personRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        personRepository.deleteAll();
    }

    @Test
    void testCreatePerson() throws Exception {
        Person person = new Person("Dupont", "Jean", Gender.MALE);
        person.setProfession("Ingénieur");
        person.setBirthDate(LocalDate.of(1990, 5, 15));

        mockMvc.perform(post("/persons")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(person)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(notNullValue()))
                .andExpect(jsonPath("$.lastName").value("Dupont"))
                .andExpect(jsonPath("$.firstNames").value("Jean"))
                .andExpect(jsonPath("$.gender").value("MALE"))
                .andExpect(jsonPath("$.profession").value("Ingénieur"));
    }

    @Test
    void testGetAllPersons() throws Exception {
        personRepository.save(new Person("Dupont", "Jean", Gender.MALE));
        personRepository.save(new Person("Martin", "Marie", Gender.FEMALE));

        mockMvc.perform(get("/persons"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].lastName").value("Dupont"))
                .andExpect(jsonPath("$[1].lastName").value("Martin"));
    }

    @Test
    void testGetPersonById() throws Exception {
        Person person = personRepository.save(new Person("Dupont", "Jean", Gender.MALE));

        mockMvc.perform(get("/persons/" + person.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(person.getId()))
                .andExpect(jsonPath("$.lastName").value("Dupont"));
    }

    @Test
    void testGetPersonByIdNotFound() throws Exception {
        mockMvc.perform(get("/persons/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Person not found with id: 999"));
    }

    @Test
    void testUpdatePerson() throws Exception {
        Person person = personRepository.save(new Person("Dupont", "Jean", Gender.MALE));

        Person update = new Person("Dupont", "Jean-Pierre", Gender.MALE);
        update.setProfession("Professeur");

        mockMvc.perform(put("/persons/" + person.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(update)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(person.getId()))
                .andExpect(jsonPath("$.firstNames").value("Jean-Pierre"))
                .andExpect(jsonPath("$.profession").value("Professeur"));
    }

    @Test
    void testDeletePerson() throws Exception {
        Person person = personRepository.save(new Person("Dupont", "Jean", Gender.MALE));

        mockMvc.perform(delete("/persons/" + person.getId()))
                .andExpect(status().isNoContent());
    }

    @Test
    void testCreatePersonWithInvalidData() throws Exception {
        Person person = new Person(null, null, null);

        mockMvc.perform(post("/persons")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(person)))
                .andExpect(status().isBadRequest());
    }
}
