#!/bin/bash

# Колір тексту
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нема кольору (скидання)

echo -e "${BLUE}Стоврення необхідних файлів.${NC}"

folder_name="gaia"

file_roles="roles.txt"
text_roles="system
user
assistant
tool"

file_phrases="phrases.txt"
text_phrases="What is the difference between functional programming and procedural programming?
Can you explain the concept of recursion with an example?
What are design patterns, and why are they important?
What is the difference between a shallow copy and a deep copy?
Explain how you would implement memoization in a program.
What is the purpose of version control systems like Git?
How does error handling work in Python or another language you are familiar with?
What is the difference between static and dynamic typing?
How does multithreading differ from multiprocessing?
What are microservices, and how do they compare to monolithic architectures?
What is the difference between heaps and binary search trees?
Can you explain the concept of dynamic programming?
How would you reverse a linked list?
What is a trie, and where is it used?
How do you merge two sorted arrays efficiently?
What is the difference between a balanced tree and an unbalanced tree?
Explain the sliding window algorithm.
How would you implement a hash map from scratch?
What is the difference between radix sort and bucket sort?
How do you find the longest common subsequence in two strings?
What are database indexes, and what are the downsides of using them?
How would you design a scalable database for an e-commerce platform?
What is a database view, and how is it used?
Explain the concept of database denormalization.
What are database triggers, and when would you use them?
How do you handle database migrations in a production environment?
What is eventual consistency in distributed databases?
Explain the concept of database replication.
What is the difference between a clustered and a non-clustered index?
What is a materialized view, and how does it differ from a standard view?
What is a CDN, and how does it work?
How would you troubleshoot a network latency issue?
Explain the difference between symmetric and asymmetric encryption.
What is ARP (Address Resolution Protocol)?
How does a traceroute work?
What are the benefits of using IPv6 over IPv4?
What is a socket, and how is it used in network programming?
Explain the concept of packet switching.
What is a VLAN, and why is it used?
How does a proxy server work?
What is the difference between paging and segmentation?
How does a scheduler decide which process to run next?
What is a race condition, and how do you prevent it?
Explain the concept of inter-process communication (IPC).
What is the purpose of a swap space?
How does an operating system manage threads?
What is the difference between user space and kernel space?
Can you explain the concept of file locking in operating systems?
What is the difference between hard and soft links in a file system?
How do you debug a kernel panic issue in Linux?
What is the difference between unit testing and integration testing?
How would you write test cases for a login functionality?
What is continuous integration and continuous delivery (CI/CD)?
Explain the concept of test-driven development (TDD).
How do you handle flaky tests in an automated test suite?
What tools do you use for debugging and profiling code?
What is the difference between black-box testing and white-box testing?
How do you identify a memory leak in an application?
What is regression testing, and why is it important?
How would you stress test a web application?
What is containerization, and how does Docker implement it?
What is Kubernetes, and how does it help manage containers?
Explain the concept of infrastructure as code (IaC).
What is the difference between public, private, and hybrid clouds?
How do you monitor the performance of cloud-based applications?
What is a load balancer, and why is it used?
What is the difference between horizontal and vertical scaling?
How does a CI/CD pipeline work?
What is a service mesh in microservices architecture?
Explain the concept of blue-green deployments.
What is the difference between authentication and authorization?
How do you ensure secure data transmission over the internet?
What are some common web application vulnerabilities?
How does two-factor authentication work?
What is cross-site scripting (XSS), and how do you prevent it?
What is a man-in-the-middle attack?
How do you secure sensitive information in an application?
What is the difference between symmetric and asymmetric encryption?
What is the role of firewalls in network security?
How do you secure APIs from unauthorized access?
What is the difference between synchronous and asynchronous communication in distributed systems?
How would you design a caching mechanism for a high-traffic web application?
Explain the CAP theorem in distributed systems.
What is the difference between event-driven and message-driven architectures?
How do you handle logging and monitoring in an application?
What is the purpose of a message queue in a distributed system?
How does a reverse proxy differ from a forward proxy?
What are webhooks, and how are they used?
How do you implement rate limiting in a web application?
What is the difference between reactive programming and imperative programming?
How does blockchain technology work?
What is the difference between edge computing and cloud computing?
How do you ensure high availability in a distributed system?
What are the key differences between HTTP/1.1 and HTTP/2?
What is the role of middleware in an application stack?
How do you prevent DDoS attacks?
What is the difference between machine learning and traditional programming?
What is a content delivery network (CDN), and why is it important?
How do you optimize the performance of a front-end application?
What is the difference between DevSecOps and traditional DevOps?
Let me know if you'd like further explanations or specific resources to study any of these topics!
What is the difference between overloading and overriding?
How does the Singleton pattern work?
What is duck typing in programming?
How do you handle exceptions in C++?
What is the difference between final, finally, and finalize in Java?
Explain the difference between GET and POST in HTTP.
What is the use of middleware in an application?
What are the benefits of using TypeScript over JavaScript?
How do you achieve polymorphism in programming?
What are promises in JavaScript, and how do they work?
Explain the observer design pattern.
How does lazy loading work in web development?
What is the difference between local storage and session storage?
What is the difference between a monorepo and a multirepo?
How do you optimize the build time of a large project?
What are WebSockets, and when should you use them?
What are soft deletes, and why might you use them?
How does hashing differ from encryption?
What is the difference between synchronous I/O and asynchronous I/O?
How would you manage environment variables in an application?
What is the difference between a max heap and a min heap?
How do you implement a breadth-first search on a graph?
What is the Floyd-Warshall algorithm used for?
How would you find the median of a large data stream?
What are bloom filters, and where are they used?
How would you implement a circular queue?
What is the difference between Kruskal’s and Prim’s algorithms?
How do you implement an LRU (Least Recently Used) cache?
What are self-balancing binary search trees?
How do you find the k-th largest element in an array?
What is the difference between merge sort and insertion sort?
How do you count the number of inversions in an array?
What is the sliding window maximum problem?
How do you find the longest palindrome substring in a given string?
What is a disjoint-set data structure?
Explain the difference between brute-force and dynamic programming.
How do you perform topological sorting on a directed graph?
How do you implement a sparse matrix?
What is the difference between a dense graph and a sparse graph?
How do you remove duplicates from an unsorted linked list?
What is a primary key, and how is it different from a unique key?
What is a composite key?
Explain the difference between ROW_NUMBER(), RANK(), and DENSE_RANK() in SQL.
What is a foreign key, and why is it used?
How do you design a many-to-many relationship in a relational database?
What is the purpose of partitioning in a database?
How does indexing affect database performance?
What is the difference between optimistic and pessimistic locking?
How would you handle data archiving in a database?
Explain the concept of eventual consistency in distributed databases.
What is a surrogate key, and how is it different from a natural key?
How do you enforce referential integrity in a relational database?
What is the difference between OLTP and OLAP?
How do you optimize the performance of a query with joins?
What are stored procedures, and when should you use them?
What is the difference between a columnar and row-based database?
What is a deadlock in a database?
How would you detect and resolve a deadlock?
How does the EXPLAIN command help in SQL optimization?
What is a materialized view, and when should you use it?
What is the purpose of a DHCP server?
How do ARP and RARP protocols work?
What is the difference between a hub, a switch, and a router?
How does TCP three-way handshake work?
What are MTU (Maximum Transmission Unit) and its importance?
How does QoS (Quality of Service) work in networking?
What are broadcast, unicast, and multicast?
What is the difference between SSL and TLS?
How does a DNS resolver work?
Explain the concept of a default gateway.
What is the role of ICMP in networking?
How does a Wi-Fi network differ from a wired network?
What is an Autonomous System (AS) in networking?
How does BGP work in routing?
What is NAT traversal, and why is it needed?
How do VLANs improve network performance?
What is a zero-trust network?
How does port forwarding work?
What are private and public IP addresses?
What is the purpose of network sniffing tools?
What are the key differences between microkernels and monolithic kernels?
How does an operating system handle deadlocks?
What is a context switch, and when does it occur?
How does demand paging improve memory efficiency?
Explain the concept of process synchronization.
What is the difference between contiguous and non-contiguous memory allocation?
What is the role of a process scheduler?
What are semaphores, and how are they used in synchronization?
How does a virtual machine differ from a container?
What is RAID, and what are its different levels?
How does an operating system manage a buffer cache?
What are shadow copies, and how do they work?
How does thread pooling work?
What is the purpose of the init process in Linux?
How do you set up a cron job in Linux?
What is the difference between FAT32 and NTFS file systems?
How do you troubleshoot disk I/O issues on a Linux server?
What is cgroups in Linux, and how is it used?
What are the differences between kernel mode and user mode?
How does the OS handle inter-process communication (IPC)?
What is Newton's first law of motion?
Define inertia.
What is the formula for force?
State Newton’s second law of motion.
How does friction affect motion?
What is the difference between static and kinetic friction?
What is the principle of conservation of momentum?
Define torque.
How is work calculated in physics?
What is the unit of energy?
Explain the difference between potential and kinetic energy.
What is the center of mass?
What factors affect gravitational force between two objects?
What is projectile motion?
How do you calculate the range of a projectile?
What is centripetal force?
Define angular velocity.
What is the difference between speed and velocity?
What is terminal velocity?
Explain Hooke’s Law.
What is the zeroth law of thermodynamics?
State the first law of thermodynamics.
Define internal energy.
What is heat capacity?
What is entropy?
How does the second law of thermodynamics relate to entropy?
What is a heat engine?
Explain the Carnot cycle.
Define thermal equilibrium.
What is latent heat?
What is the Kelvin scale?
Explain the difference between conduction, convection, and radiation.
What is the specific heat of a substance?
What is the triple point of water?
How does a refrigerator work in terms of thermodynamics?
Define adiabatic process.
What is an isothermal process?
How is efficiency of a heat engine calculated?
What is absolute zero?
What is the Boltzmann constant?
Waves and Oscillations
What is simple harmonic motion?
What is the equation for the period of a pendulum?
Define amplitude in wave motion.
What is frequency?
How are wavelength and frequency related?
What is the Doppler effect?
What is resonance?
Explain constructive and destructive interference.
What is a standing wave?
How is wave speed calculated?
What is the principle of superposition?
What are longitudinal waves?
What are transverse waves?
Define phase difference.
What is a node in a standing wave?
What is sound intensity?
How is the decibel scale defined?
What is the speed of sound in air?
How does temperature affect the speed of sound?
What is ultrasound?
Define electric charge.
State Coulomb's law.
What is an electric field?
How is electric potential defined?
What is capacitance?
What are conductors and insulators?
Define Ohm’s Law.
What is a resistor?
What is the unit of electrical resistance?
What is an electric circuit?
What is electromagnetic induction?
State Faraday’s law.
What is Lenz’s law?
Define magnetic flux.
What is a solenoid?
Explain the concept of alternating current (AC).
What is a transformer?
What is the right-hand rule in electromagnetism?
What is the difference between paramagnetic and diamagnetic materials?
What are Maxwell’s equations?
What is reflection?
Define refraction.
What is Snell's law?
What is the critical angle?
What is total internal reflection?
Define dispersion in optics.
What causes a rainbow?
What is the lens maker's formula?
What is the difference between convex and concave lenses?
Define focal length.
What is the difference between real and virtual images?
What is diffraction?
What is interference in light waves?
What is polarization of light?
What is Brewster’s angle?
What is Huygens’ principle?
Define optical fiber.
What is monochromatic light?
What is the principle behind a prism?
How do lasers work?
What is the theory of relativity?
What is time dilation?
Define mass-energy equivalence.
What is the photoelectric effect?
What is Planck’s constant?
What is quantum mechanics?
Define wave-particle duality.
What is Heisenberg’s uncertainty principle?
What is a photon?
What is Schrödinger’s equation?
What is a black body?
Define atomic nucleus.
What are isotopes?
What is nuclear fission?
What is nuclear fusion?
What is a half-life?
What is antimatter?
What is dark matter?
Define the Big Bang theory.
What are quarks?
What is a star?
How is a black hole formed?
What is the speed of light in a vacuum?
Define redshift in astronomy.
What is the Hubble constant?
What is a supernova?
What is the lifecycle of a star?
Define exoplanet.
What is a galaxy?
How are distances in space measured?
What is the cosmic microwave background radiation?
What are neutron stars?
What is the event horizon of a black hole?
What is a pulsar?
Define gravitational lensing.
What is the observable universe?
What is the multiverse theory?
What is dark energy?
What is the difference between an asteroid and a comet?
What is the significance of the Hertzsprung-Russell diagram?
What is dimensional analysis?
What is the SI system of units?
Define scalar and vector quantities.
What is a frame of reference?
How is power defined in physics?
What is the principle of equivalence?
Define escape velocity.
What are Kepler’s laws of planetary motion?
What is a geostationary orbit?
How is radiation pressure calculated?
What is a tachyon?
What is a Bose-Einstein condensate?
Define the term plasma.
What is superconductivity?
What is a gravitational wave?
What is entropy in information theory?
Define the term ideal gas.
What is Brownian motion?
What is the Coriolis effect?
What is the Michelson-Morley experiment?
What is the principle of a rocket?
How does a gyroscope work?
What is the difference between a motor and a generator?
How does radar work?
What is an accelerometer?
What is MRI technology?
What is ultrasound imaging?
Define semiconductor.
What is fiber optics used for?
How does GPS technology work?
What is an electric motor?
How do solar panels work?
What is the principle behind a wind turbine?
What is a thermocouple?
What is superconducting material used for?
What is a photovoltaic cell?
How do X-rays work?
What is a spectrometer?
What is the function of a particle accelerator?
What is cryogenics?
What is string theory?
What is quantum entanglement?
Define gravitational time dilation.
What are black hole singularities?
What is the standard model of particle physics?
What is a gluon?
What are gravitational waves?
What is the Higgs boson?
What is the concept of a wormhole?
What is the theory of everything?
What are neutrinos?
What is supersymmetry?
Define the quantum field theory.
What is quantum tunneling?
What are virtual particles?
What is cosmology?
What is the Planck scale?
What are the implications of Hawking radiation?
What is the Anthropic principle?
What is quantum computing?
What is an atom?
What is a molecule?
Define an ion.
What is the atomic number?
What is an isotope?
Define atomic mass.
What are the three subatomic particles?
What is the difference between a cation and an anion?
What is the periodic table?
Who is credited with the creation of the periodic table?
What is an electron configuration?
What is a chemical bond?
Define valence electrons.
What is the octet rule?
What is ionization energy?
What is electron affinity?
Define electronegativity.
What are the alkali metals?
What are the noble gases?
Define transition metals.
What are the three primary states of matter?
Define plasma.
What is the kinetic molecular theory of matter?
What is Boyle’s Law?
What is Charles's Law?
What is Avogadro’s Law?
What is the ideal gas law?
Define critical point.
What is the difference between a solid, liquid, and gas?
What is vapor pressure?
How do gases behave in terms of diffusion?
Define condensation.
What is boiling point?
How does temperature affect gas volume?
What is sublimation?
What is deposition?
What is an amorphous solid?
Define a crystalline solid.
What is a chemical reaction?
What is the law of conservation of mass?
What are reactants and products?
What is a catalyst?
What is an exothermic reaction?
What is an endothermic reaction?
What is activation energy?
What is the difference between a physical and a chemical change?
What are oxidation and reduction?
What is combustion?
What is a redox reaction?
Define the term “stoichiometry.”
What is the mole concept?
What is a limiting reagent?
What is the molecular weight?
What is a balanced chemical equation?
What is a precipitation reaction?
What is a double displacement reaction?
What is a single displacement reaction?
Define synthesis reaction.
What is decomposition?
What is a combustion reaction?
What is enthalpy?
What is the difference between heat and temperature?
What is the first law of thermodynamics?
What is entropy?
Define Gibbs free energy.
What is Hess’s Law?
What is calorimetry?
What is a heat of fusion?
What is the heat of vaporization?
Define specific heat capacity.
What is the difference between exothermic and endothermic reactions?
How is energy transferred in chemical reactions?
What is a solution?
What is solubility?
What is a solvent?
What is a solute?
What is molarity?
What is molality?
What is the difference between a dilute and concentrated solution?
What is the relationship between temperature and solubility?
What is the principle of like dissolves like?
What is a saturated solution?
What is an unsaturated solution?
What is a supersaturated solution?
How does temperature affect the rate of dissolution?
What is an acid?
What is a base?
Define the pH scale.
What is the difference between strong and weak acids?
What is a neutralization reaction?
What is the Bronsted-Lowry theory of acids and bases?
What is the Lewis definition of acids and bases?
What is the dissociation of water?
How does a buffer solution work?
What is a titration?
What is the difference between a monoprotic and diprotic acid?
What are amphoteric substances?
What is an organic compound?
What are hydrocarbons?
What is an alkane?"

# Зчитування Node_ID
gaia_ids=output=$(gaianet info)
node_id=$(echo "$gaia_ids" | sed 's/\x1b\[[0-9;]*m//g' | sed -n '1p' | cut -d':' -f2 | tr -d ' ')

# Формування бота
file_bot="gaia_bot.py"
text_bot='import aiohttp
import asyncio
import random

# URL API
url = "https://[NODE_ID].gaia.domains/v1/chat/completions"

# Заголовки запроса
headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

# Функция для чтения ролей и фраз из файлов
def load_from_file(file_name):
    with open(file_name, "r") as file:
        return [line.strip() for line in file.readlines()]

# Загрузка ролей и фраз
roles = load_from_file("roles.txt")
phrases = load_from_file("phrases.txt")

# Генерация случайного сообщения
def generate_random_message():
    role = random.choice(roles)
    content = random.choice(phrases)
    return {"role": role, "content": content}

# Создание сообщения
def create_message():
    """Создаёт сообщение, гарантируя, что одно из них имеет роль \"user\"."""
    user_message = generate_random_message()
    user_message["role"] = "user"  # Гарантируем, что хотя бы одно сообщение — от \"user\"
    other_message = generate_random_message()
    return [user_message, other_message]

# Отправка запроса к API
async def chat_loop():
    async with aiohttp.ClientSession() as session:
        while True:
            messages = create_message()
            user_message = next((msg["content"] for msg in messages if msg["role"] == "user"), "No user message found")

            # Логируем отправленный вопрос
            print(f"Отправлен вопрос: {user_message}")

            data = {"messages": messages}

            try:
                async with session.post(url, json=data, headers=headers, timeout=60) as response:
                    if response.status == 200:
                        result = await response.json()
                        assistant_response = result["choices"][0]["message"]["content"]
                        print(f"Получен ответ: {assistant_response}\\n{'\''-'\''*50}")
                    else:
                        print(f"Ошибка: {response.status} - {await response.text()}")
            except asyncio.TimeoutError:
                print("Тайм-аут ожидания. Отправляю следующий запрос...")
            except Exception as e:
                print(f"Ошибка: {e}")

            # Небольшая задержка перед отправкой следующего сообщения
            await asyncio.sleep(1)

if __name__ == "__main__":
    asyncio.run(chat_loop())
'
text_bot_final="${text_bot/\[NODE_ID\]/$node_id}"

# Створення папки
mkdir -p "$folder_name"

# Запис тексту у файл
echo -e "$text_roles" > "$folder_name/$file_roles"
echo -e "$text_phrases" > "$folder_name/$file_phrases"
echo -e "$text_bot_final" > "$folder_name/$file_bot"

echo -e "${GREEN}Необхідіні файли створено.${NC}"

# Налаштування оточення
source venv/bin/activate

# Запуск сессії
cd gaia
tmux new -s gaia 'python3 gaia_bot.py'
