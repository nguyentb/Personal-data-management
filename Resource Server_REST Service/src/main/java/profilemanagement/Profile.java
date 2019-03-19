package profilemanagement;

import org.springframework.data.annotation.Id;

public class Profile {
	
	@Id private String id;
    private String firstName;
    private String lastName;
    private int age;
    private String email;
    private long timestamp;
    

    public Profile(String firstName, String lastName, int age, String email, long timestamp) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.age = age;
        this.email = email;
        this.timestamp = timestamp;
    }

    public String getId() {
        return id;
    }

    public double getAge() {
        return age;
    }
    
    public String getFirstName() {
        return firstName;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public String getEmail() {
        return email;
    }
    
    public long getTimestamp() {
        return timestamp;
    }

}