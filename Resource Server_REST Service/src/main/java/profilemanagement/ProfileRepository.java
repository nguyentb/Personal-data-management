
package profilemanagement;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "profile", path = "profile")
public interface ProfileRepository extends MongoRepository<Profile, String> {

	Optional<Profile> findById(@Param("id") String id);
	List<Profile> findByLastName(@Param("lastName") String lastName);
	List<Profile> findByFirstName(@Param("firstName") String firstName);
	List<Profile> findByEmail(@Param("email") String email);

}