// :::::::::::::::::::::::::::::::::::::::::
// ::                                     ::
// ::  Question 7. Problème stationnaire  ::
// ::                                     ::
// :::::::::::::::::::::::::::::::::::::::::
funcprot(0);
exec("Q3_Factorisation_Cholesky.sce");
exec("Q4_Descente_Cholesky.sce");
exec("Q5_Remontee_Cholesky.sce");


// CONSTANTES DE LA SIMULATION
// Demi-longueur de la barre métallique
l = 13;

// FONCTIONS A UNE VARIABLE REELLE
// Fonction de conductivité simplifiée
function res = C(x)
    res = exp(-x / l);
endfunction

// Solution exacte de l'équation différentielle au point x
function res = probleme_stationnaire(x)
    res = (%e * (%e - exp(x/l)))/(exp(2) - 1);
endfunction


// :::::::::::::::::::::::::
// :: CALCULS DE MATRICES ::
// :::::::::::::::::::::::::

// Calcul de la matrice A, tridiagonale
function [matrice_A_diag, matrice_A_inf] = calcul_A(n)
    matrice_A_diag = zeros(n, 1);
    matrice_A_inf = zeros(n-1, 1);

    delta_x = (2 * l)/(n + 1);
    i = 1;

    // Arrêt une itération plus tôt, on ne doit pas écrire matrice_A_inf(n)
    for x = -l+delta_x:delta_x:l-2*delta_x
        matrice_A_diag(i) = C(x + delta_x / 2) + C(x - delta_x / 2);
        matrice_A_inf(i) = -C(x + delta_x / 2);

        i = i + 1
    end

    matrice_A_diag(n) = C(l - delta_x / 2) + C(l - 3 * (delta_x / 2));
endfunction


// Calcul de la matrice B, matrice-colonne
function [matrice_B] = calcul_B(n)
    delta_x = (2 * l)/(n + 1);

    matrice_B = zeros(n, 1);
    matrice_B(1) = C(-l + (delta_x/2));
endfunction

// Discrétisation de la solution exacte
// pour la mettre sur le même plan que la solution numérique approchée
function [v_ps] = discretiser(fonc, delta_x, n)
    v_ps = zeros(n, 1);
    i = 1

    for x = -l:delta_x:l-2*delta_x
        v_ps(i) = fonc(x)
        i = i + 1
    end
endfunction


// QUESTION 7
// DECOMPOSITION DE CHOLESKY
function question_7()
    clf;
    n_min = 50;
    n_step = 100;
    n_max = 5000;

    for n = n_min:n_step:n_max
        delta_x = (2 * l)/(n + 1);
        B = calcul_B(n);

        [A_diag, A_inf] = calcul_A(n);
        [F_diag, F_inf] = factorise(A_diag, A_inf);

        v_descente = descente(F_diag, F_inf, B);
        v_remonte = remonte(F_diag, F_inf, v_descente);

        // On affiche en norme infinie la différence des deux solutions
        v_ps = discretiser(probleme_stationnaire, delta_x, n);
        resultat($ + 1) = norm(v_remonte - v_ps, 'inf');
    end

    // Affichage graphique
    plot((n_min:n_step:n_max)', resultat);
    xtitle("Norme infinie de la différence entre solution exacte et solution approchée");
endfunction

// APPEL DE LA QUESTION 7
question_7();
