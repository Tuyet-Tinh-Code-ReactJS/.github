workspace {

    model {
        normalUser = person "Anonymous User" "A user can do business in the application without login" "Users"
        authorizeUser = person "Authorized User" "A user have login into the application""Users"
        adminUser = person "Admin User" "A user can manage the application such as setup user, manage questions""Users"
        enterprise "Driving Testing System" {            
            coreSystem = softwareSystem "Core System" "Services inside product"{
                frontendWeb = container "Single Page Web Application" "The website for demonstrate the ability of the application" "JavaScript and ReactJS" "Web Browser"{
                    webView = component "Views" "web pages and render html to browser" "ReactJS JSX"
                    httpService = component "Http Client" "Make APIs call to backend" "Axios"
                }
                apiGateway = container "Api Gateway" "Routing requests to destination service" "NET 6 and Ocelot"{
                    ocelotClient = component "Ocelot Component" "Handling all the API Gateway features"                    
                    consulClient = component "Consul Client" "Integration with Consul Service Registry"
                }
                accountService = container "Account Service" "Store user information" "NET 6 Web APIs"{
                    accountController = component "Account Controller" "Provide APIs that allow user authentication" "Web API Controller"
                    keycloakService = component "Keycloak Service" "Call keycloak api for login user" "C# and Http Client"
                    adminKeycloakService = component "Admin Keycloak Service" "Call keycloak for search, change password user" "C# and Http Client"
                    kafkaProducerService = component "Kafka Producer Service" "Send event to kafka message broker" "Kafka Client"
                    accountConsulService = component "Consul Service" "Integration with Consul Service Registry"
                }
                catalogService = container "Catalog Service" "Provides Driving Test functionality via a JSON/HTTPS API" "NET 6 Web APIs"{
                    catalogController = component "Catalog Controller" "Provide APIs that allow user get data, do test and view result" "Web API Controller"
                    repository = component "Repository" "Read driving test information from database and write test's user to" "Entity Framework Core"
                    catalogContext = component "Catalog Context" "Provide CRUD methods to physical database"
                    catalogConsulService = component "Consul Service" "Integration with Consul Service Registry"
                    cachedService = component "Caching Service" "Caching database query"
                }
                notificationService = container "Notification Service" "Sends e-mails to users" "NET 6 Web APIs"{
                    emailService = component "Email Service" "Send email to user" "C# and STMP Client"
                    kafkaConsumerService = component "Kafka Consumer Service" "Consume event and initial handler"
                    eventHandler = component "Event Handler" "Handling events receive from kafka consumer"
                }
                fileService = container "File Service" "A facade into the Minio Storage System." "NET 6 Web APIs"{
                    storageService = component "Storage Service" "Put object to minio storage" "Minio Client"
                    filesController = component "File Controler" "Provide APIs that allow user upload files" "Web API Controller"
                    fileConsulService = component "Consul Service" "Integration with Consul Service Registry"
                }
            }
            databaseSystem = softwareSystem "Postgresql" "Manage database for all service in the application" "Existing System"
            messageBroker = softwareSystem "Kafka" "The message broker for all service in the application""Existing System"
            cachedSystem = softwareSystem "Redis" "The cache engine for all service in the application""Existing System"
            keycloakSystem = softwareSystem "Keycloak Identity Server" "The external identity providers""Existing System"
            storageSystem = softwareSystem "Minio Storage" "The external storage providers""Existing System"
            serviceRegistry = softwareSystem "Consul Service Registry" "Discover services with DNS or HTTP""Existing System"
        }
        # relationships between people and core system
        normalUser -> frontendWeb "Uses"
        authorizeUser -> frontendWeb "Uses"
        adminUser -> frontendWeb "Uses"

                
        
        
        # relationships between core system and existing system
        coreSystem -> keycloakSystem "Verify token, CRUD user" "REST/JSON"
        coreSystem -> databaseSystem "Uses" "TCP"
        coreSystem -> messageBroker "Uses" "TCP"
        coreSystem -> cachedSystem "Uses" "TCP"
        coreSystem -> storageSystem "Uses" "TCP"
        coreSystem -> serviceRegistry "Uses" "TCP"
        frontendWeb -> storageSystem "Get image to show on website" "HTTP/HTTPS"

        # relationships to/from containers
        frontendWeb -> keycloakSystem "OAuth 2"
        frontendWeb -> apiGateway "Web calls to services to get data" "REST/JSON"
        apiGateway -> accountService "Forwarding account request" "TCP"
        apiGateway -> catalogService "Forwarding catalog request" "TCP"
        apiGateway -> fileService "Forwarding upload file request" "TCP"
        accountService -> messageBroker "Procedure event" "Pub/Sub event"
        messageBroker -> notificationService "Consumer event" "Pub/Sub event"
        notificationService -> authorizeUser "Sends e-mails to" "NET 6 and SMTP Client"
        fileService -> storageSystem "Put object to storage" "NET 6 and Amazon S3 Client"
        accountService -> keycloakSystem "Gets account information from, Create account" "REST/JSON"

        accountService -> serviceRegistry "Registry service" "TCP"
        catalogService -> serviceRegistry "Registry service" "TCP"
        fileService -> serviceRegistry "Registry service" "TCP"
        notificationService -> serviceRegistry "Registry service" "TCP"

        # relationships to/from components
        # frontend
        normalUser -> webView "Visit omtest.online using" "HTTPS"
        authorizeUser -> webView "View account, do test" "HTTPS"
        adminUser -> webView "Manage user, driving test information" "HTTPS"
        webView -> httpService "Call Facade APIs" "Javascript"
        httpService -> apiGateway "Make APIs" "Axios"
        storageSystem -> webView "Send image to browser"
        # api gateway
        frontendWeb -> ocelotClient "Make API calls to ""JSON/HTTPS"
        ocelotClient -> accountController "forwarding" "TCP"
        ocelotClient -> catalogController "forwarding" "TCP"
        ocelotClient -> filesController "forwarding" "TCP"
        ocelotClient -> consulClient "Get services address" "TCP"        
        serviceRegistry -> consulClient "Get service address"
        # account service
        accountController -> keycloakService "login user and generate token" "JSON/HTTP"
        accountController -> adminKeycloakService "get/set user information" "JSON/HTTP"
        accountController -> kafkaProducerService "produre event" "Kafka Client"
        accountController -> accountConsulService "Manage registry service"
        accountConsulService -> serviceRegistry "Registry account service to consul" "TCP"
        keycloakService -> keycloakSystem "integration" "JSON/HTTP"
        adminKeycloakService -> keycloakSystem "integration" "JSON/HTTP"
        kafkaProducerService -> messageBroker "integration" "TCP"
        # catalog service
        catalogController -> repository "implement CRUD" "Entity Framework Core 6.0"
        catalogController -> catalogConsulService "Registry catalog service to consul" "TCP"
        repository -> catalogContext "Use" "Entity Framework Core 6.0"
        catalogContext -> databaseSystem "Use" "Entity Framework Core 6.0"
        catalogController -> cachedService "Use" "Redis client"
        cachedService -> cachedSystem "Use" "TCP"
        catalogConsulService -> serviceRegistry "Registry catalog service" "TCP"
        # notification service
        messageBroker -> kafkaConsumerService "Consume event" "Kafka Client"
        kafkaConsumerService -> eventHandler "Implement event handler" "C# and Mediator Library"
        eventHandler -> emailService "Use" "C#"
        emailService -> authorizeUser "Send mail to users" "C# and Smtp Client"
        # file service
        filesController -> storageService "Use"
        storageService -> storageSystem "Store object" "TCP"
        filesController -> fileConsulService "Use" "TCP"
        fileConsulService -> serviceRegistry "Registry file service to consul"

        deploymentEnvironment "Development" {
            deploymentNode "Digital Occean VPS" ""{
                deploymentNode "Web Browser" "Chrome, Firefox, Safari, Edge" {
                    singlePageApplicationInstance = containerInstance frontendWeb
                }
                deploymentNode "Nginx Web Server" "" "Nginx 1.2"{
                    deploymentNode "Docker Container" "" "Docker" {
                        apiGatewayInstance = containerInstance apiGateway                        
                    }
                }
                deploymentNode "Core Services" "" "Docker" {                    
                    accountServiceInstance = containerInstance accountService
                    catalogServiceInstance = containerInstance catalogService
                    fileServiceInstance = containerInstance fileService
                    notificationServiceInstance = containerInstance notificationService                    
                }
                deploymentNode "Database Server" "" "Docker" {
                    databaseSystemInstance = softwareSystemInstance databaseSystem
                }                
                deploymentNode "Storage Center" "" "Docker" {
                    storageSystemInstance = softwareSystemInstance storageSystem
                }                
                deploymentNode "Message Broker" "" "Docker" {
                    messageBrokerInstance = softwareSystemInstance messageBroker
                }                                
                deploymentNode "Identity Server" "" "Docker" {
                    keycloakSystemInstance = softwareSystemInstance keycloakSystem
                }
            }
        }
    }

    views {        
        systemlandscape "SystemLandscape" {
            include *
            autoLayout
        }

        container coreSystem "CoreSystem" {
            include *            
            autoLayout
        }

        component frontendWeb "frontendWeb"{
            include *            
            autoLayout
        }

        component apiGateway "apiGateway"{
            include *            
            autoLayout
        }

        component accountService "accountService"{
            include *            
            autoLayout
        }

        component catalogService "catalogService"{
            include *            
            autoLayout
        }

        component notificationService "notificationService"{
            include *            
            autoLayout
        }

        component fileService "fileService"{
            include *            
            autoLayout
        }

        deployment coreSystem "Development" "DevelopmentDeployment" {
            include *
            autoLayout
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Users" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Existing System"{
                background #999999
                color #ffffff
            }
        }
    }
    
}