package com.familytree.person.service;

import com.familytree.person.exception.PersonNotFoundException;
import com.familytree.person.model.Person;
import com.familytree.person.repository.PersonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class PersonService {

    private final PersonRepository personRepository;

    public PersonService(PersonRepository personRepository) {
        this.personRepository = personRepository;
    }

    public Person create(Person person) {
        return personRepository.save(person);
    }

    @Transactional(readOnly = true)
    public List<Person> findAll() {
        return personRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Person findById(Long id) {
        return personRepository.findById(id)
                .orElseThrow(() -> new PersonNotFoundException(id));
    }

    public Person update(Long id, Person person) {
        Person existingPerson = findById(id);
        existingPerson.setLastName(person.getLastName());
        existingPerson.setFirstNames(person.getFirstNames());
        existingPerson.setGender(person.getGender());
        existingPerson.setProfession(person.getProfession());
        existingPerson.setBirthDate(person.getBirthDate());
        existingPerson.setBirthPlace(person.getBirthPlace());
        existingPerson.setNotes(person.getNotes());
        return personRepository.save(existingPerson);
    }

    public void delete(Long id) {
        Person person = findById(id);
        personRepository.delete(person);
    }
}
