package com.familytree.person;

import com.familytree.person.model.Gender;
import com.familytree.person.model.Person;
import com.familytree.person.repository.PersonRepository;
import com.familytree.person.service.PersonService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class PersonServiceTest {

    @Autowired
    private PersonService personService;

    @Autowired
    private PersonRepository personRepository;

    @BeforeEach
    void setUp() {
        personRepository.deleteAll();
    }

    @Test
    void testCreatePerson() {
        Person person = new Person("Dupont", "Jean", Gender.MALE);
        person.setProfession("Ingénieur");
        person.setBirthDate(LocalDate.of(1990, 5, 15));
        person.setBirthPlace("Paris");

        Person saved = personService.create(person);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getLastName()).isEqualTo("Dupont");
        assertThat(saved.getFirstNames()).isEqualTo("Jean");
        assertThat(saved.getGender()).isEqualTo(Gender.MALE);
        assertThat(saved.getProfession()).isEqualTo("Ingénieur");
        assertThat(saved.getBirthDate()).isEqualTo(LocalDate.of(1990, 5, 15));
        assertThat(saved.getBirthPlace()).isEqualTo("Paris");
    }

    @Test
    void testFindAll() {
        Person person1 = personService.create(new Person("Dupont", "Jean", Gender.MALE));
        Person person2 = personService.create(new Person("Martin", "Marie", Gender.FEMALE));

        List<Person> persons = personService.findAll();

        assertThat(persons).hasSize(2);
        assertThat(persons).extracting(Person::getLastName).containsExactlyInAnyOrder("Dupont", "Martin");
    }

    @Test
    void testFindById() {
        Person person = personService.create(new Person("Dupont", "Jean", Gender.MALE));

        Person found = personService.findById(person.getId());

        assertThat(found.getId()).isEqualTo(person.getId());
        assertThat(found.getLastName()).isEqualTo("Dupont");
    }

    @Test
    void testFindByIdNotFound() {
        assertThatThrownBy(() -> personService.findById(999L))
                .isInstanceOf(Exception.class)
                .hasMessageContaining("Person not found");
    }

    @Test
    void testUpdatePerson() {
        Person person = personService.create(new Person("Dupont", "Jean", Gender.MALE));

        Person update = new Person("Dupont", "Jean-Pierre", Gender.MALE);
        update.setProfession("Professeur");
        update.setBirthDate(LocalDate.of(1985, 3, 20));
        update.setNotes("Modifié");

        Person updated = personService.update(person.getId(), update);

        assertThat(updated.getId()).isEqualTo(person.getId());
        assertThat(updated.getFirstNames()).isEqualTo("Jean-Pierre");
        assertThat(updated.getProfession()).isEqualTo("Professeur");
        assertThat(updated.getBirthDate()).isEqualTo(LocalDate.of(1985, 3, 20));
        assertThat(updated.getNotes()).isEqualTo("Modifié");
    }

    @Test
    void testDeletePerson() {
        Person person = personService.create(new Person("Dupont", "Jean", Gender.MALE));
        Long id = person.getId();

        personService.delete(id);

        Optional<Person> deleted = personRepository.findById(id);
        assertThat(deleted).isEmpty();
    }

    @Test
    void testCreateWithMinimalFields() {
        Person person = new Person("Durand", "Paul", Gender.OTHER);

        Person saved = personService.create(person);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getLastName()).isEqualTo("Durand");
        assertThat(saved.getFirstNames()).isEqualTo("Paul");
        assertThat(saved.getGender()).isEqualTo(Gender.OTHER);
        assertThat(saved.getProfession()).isNull();
        assertThat(saved.getBirthDate()).isNull();
        assertThat(saved.getBirthPlace()).isNull();
        assertThat(saved.getNotes()).isNull();
    }
}
