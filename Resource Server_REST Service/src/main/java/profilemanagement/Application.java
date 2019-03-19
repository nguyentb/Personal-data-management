
package profilemanagement;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
	
	@Bean
	public CommandLineRunner ProfileCreate(ProfileRepository prepo) {
    	return (args) ->
    	{
			for (int i = 1; i < 10; i++){
				prepo.save(new Profile("Nguyen " + i, "Truong " + i, i+20, "ntruong@imperial.ac.uk", System.currentTimeMillis()));
			}
		
    	};
    }
}