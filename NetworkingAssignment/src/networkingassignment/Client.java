 package networkingassignment;

import java.io.*;
import java.net.Socket;
import java.util.Scanner;

/**
 *
 * @author Bara Wazwaz
 */
public class Client {
    
    static Scanner userInput;
    static {
        userInput = new Scanner(System.in);
    }
    
    public static void main(String[] args) {
        final int portNumber = 12345;
        final String host = "localhost"; // alias for "127.0.0.1"
        
        // Forming Connection/Handshake
        try (
            Socket socket = new Socket(host, portNumber);
        ) {
            
            // IO Coupling
            try (
                BufferedReader clientInput = new BufferedReader(
                    new InputStreamReader(socket.getInputStream())
                );
                PrintWriter clientOutput = new PrintWriter(
                    new OutputStreamWriter(socket.getOutputStream()), 
                    true // auto flush
                );
            ) {

                // Confirming Successful Connection
                System.out.println("Connected to Server at " + host + ":" + portNumber);
                
                // Exchange
                String userMessage = "";
                while (true) {
                    while (userMessage.trim().equals("")) {
                        System.out.print("> ");
                        userMessage = userInput.nextLine();
                    }
                    clientOutput.println(userMessage);
                    System.out.println(clientInput.readLine());
                    if (userMessage.trim().equals("quit"))
                        break;
                    userMessage = "";
                }
            }
            catch (IOException e) {
                System.out.println("An issue has occurred while creating the IO Coupling");
                System.out.println("Error Message : " + e.getMessage());
            }
        }
        catch (IOException e) {
            System.out.println("An issue has occurred while forming the Forming Connection/Handshake");
            System.out.println("Error Message : " + e.getMessage());
        }
    }
}
