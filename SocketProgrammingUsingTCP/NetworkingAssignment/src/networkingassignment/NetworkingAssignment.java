/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package networkingassignment;

import java.util.ArrayList;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 *
 * @author Bara Wazwaz
 */
public class NetworkingAssignment {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        ArrayList<Callable<Void>> programs = new ArrayList<>();
        
        programs.add((Callable<Void>) () -> {
            Server.main(new String[0]);
            return null;
        });
        programs.add((Callable<Void>) () -> {
            Client.main(new String[0]);
            return null;
        });
                
        ExecutorService parallelRunner = Executors.newFixedThreadPool(3);
        try {
            parallelRunner.invokeAll(programs);
        }
        catch (InterruptedException e) {
            System.out.println("Error : " + e.getMessage());
        }
    }
    
}
