package com.example.driverservice.service;

import com.example.driverservice.model.Ride;
import com.example.driverservice.model.RideStatus;
import com.example.driverservice.repository.RideRepository;
import dto.AppErrorCode;
import dto.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RideServiceTest {

    @Mock
    private RideRepository rideRepository;

    @InjectMocks
    private RideService rideService;

    private Long testDriverId;
    private Long testCampaignId;
    private Ride testRide;

    @BeforeEach
    void setUp() {
        testDriverId = 1L;
        testCampaignId = 10L;

        testRide = new Ride();
        testRide.setId(1L);
        testRide.setDriverId(testDriverId);
        testRide.setCampaignId(testCampaignId);
        testRide.setStartTime(LocalDateTime.now());
        testRide.setStatus(RideStatus.ACTIVE);
    }

    // ===== START RIDE TESTS =====

    @Test
    void startRide_ShouldCreateNewRide_WhenNoActiveRideExists() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.empty());
        when(rideRepository.save(any(Ride.class))).thenReturn(testRide);

        // When
        Ride result = rideService.startRide(testDriverId, testCampaignId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getDriverId()).isEqualTo(testDriverId);
        assertThat(result.getCampaignId()).isEqualTo(testCampaignId);
        assertThat(result.getStatus()).isEqualTo(RideStatus.ACTIVE);
        verify(rideRepository).save(any(Ride.class));
    }

    @Test
    void startRide_ShouldThrowException_WhenDriverHasActiveRide() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.of(testRide));

        // When & Then
        assertThatThrownBy(() -> rideService.startRide(testDriverId, testCampaignId))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.RIDE_ALREADY_STARTED);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    @Test
    void startRide_ShouldThrowException_WhenDriverIdIsNull() {
        // When & Then
        assertThatThrownBy(() -> rideService.startRide(null, testCampaignId))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.VALIDATION_ERROR);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    // ===== STOP RIDE TESTS =====

    @Test
    void stopRide_ShouldCompleteRide_WhenActiveRideExists() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.of(testRide));
        
        when(rideRepository.save(any(Ride.class))).thenAnswer(invocation -> {
            Ride savedRide = invocation.getArgument(0);
            return savedRide;
        });

        // When
        Ride result = rideService.stopRide(testDriverId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(RideStatus.COMPLETED);
        assertThat(result.getEndTime()).isNotNull();
        assertThat(result.getDuration()).isNotNull();
        verify(rideRepository).save(any(Ride.class));
    }

    @Test
    void stopRide_ShouldThrowException_WhenNoActiveRideExists() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> rideService.stopRide(testDriverId))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.RIDE_NOT_ACTIVE);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    @Test
    void stopRide_ShouldThrowException_WhenDriverIdIsNull() {
        // When & Then
        assertThatThrownBy(() -> rideService.stopRide(null))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.VALIDATION_ERROR);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    // ===== GET RIDE HISTORY TESTS =====

    @Test
    void getRideHistory_ShouldReturnListOfRides() {
        // Given
        Ride ride1 = new Ride();
        ride1.setId(1L);
        ride1.setDriverId(testDriverId);
        ride1.setStatus(RideStatus.COMPLETED);

        Ride ride2 = new Ride();
        ride2.setId(2L);
        ride2.setDriverId(testDriverId);
        ride2.setStatus(RideStatus.VERIFIED);

        List<Ride> expectedRides = Arrays.asList(ride2, ride1); // Newest first

        when(rideRepository.findByDriverIdOrderByStartTimeDesc(testDriverId))
                .thenReturn(expectedRides);

        // When
        List<Ride> result = rideService.getRideHistory(testDriverId);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result).containsExactly(ride2, ride1);
        verify(rideRepository).findByDriverIdOrderByStartTimeDesc(testDriverId);
    }

    @Test
    void getRideHistory_ShouldReturnEmptyList_WhenNoRidesExist() {
        // Given
        when(rideRepository.findByDriverIdOrderByStartTimeDesc(testDriverId))
                .thenReturn(List.of());

        // When
        List<Ride> result = rideService.getRideHistory(testDriverId);

        // Then
        assertThat(result).isEmpty();
        verify(rideRepository).findByDriverIdOrderByStartTimeDesc(testDriverId);
    }

    // ===== GET ACTIVE RIDE TESTS =====

    @Test
    void getActiveRide_ShouldReturnRide_WhenActiveRideExists() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.of(testRide));

        // When
        Ride result = rideService.getActiveRide(testDriverId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(testRide.getId());
        assertThat(result.getStatus()).isEqualTo(RideStatus.ACTIVE);
        verify(rideRepository).findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE);
    }

    @Test
    void getActiveRide_ShouldThrowException_WhenNoActiveRideExists() {
        // Given
        when(rideRepository.findByDriverIdAndStatus(testDriverId, RideStatus.ACTIVE))
                .thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> rideService.getActiveRide(testDriverId))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.RIDE_NOT_ACTIVE);
    }

    // ===== VERIFY RIDE TESTS =====

    @Test
    void verifyRide_ShouldVerifyRide_WhenRideIsCompleted() {
        // Given
        Long rideId = 1L;
        String qrCode = "QR123456";
        
        Ride completedRide = new Ride();
        completedRide.setId(rideId);
        completedRide.setDriverId(testDriverId);
        completedRide.setStatus(RideStatus.COMPLETED);
        
        Ride verifiedRide = new Ride();
        verifiedRide.setId(rideId);
        verifiedRide.setStatus(RideStatus.VERIFIED);
        verifiedRide.setQrCodeData(qrCode);

        when(rideRepository.findById(rideId)).thenReturn(Optional.of(completedRide));
        when(rideRepository.save(any(Ride.class))).thenReturn(verifiedRide);

        // When
        Ride result = rideService.verifyRide(rideId, qrCode);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(RideStatus.VERIFIED);
        assertThat(result.getQrCodeData()).isEqualTo(qrCode);
        verify(rideRepository).save(any(Ride.class));
    }

    @Test
    void verifyRide_ShouldThrowException_WhenRideNotFound() {
        // Given
        Long rideId = 999L;
        when(rideRepository.findById(rideId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> rideService.verifyRide(rideId, "QR123"))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.RIDE_NOT_ACTIVE);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    @Test
    void verifyRide_ShouldThrowException_WhenRideIsNotCompleted() {
        // Given
        Long rideId = 1L;
        testRide.setStatus(RideStatus.ACTIVE); // Still active
        
        when(rideRepository.findById(rideId)).thenReturn(Optional.of(testRide));

        // When & Then
        assertThatThrownBy(() -> rideService.verifyRide(rideId, "QR123"))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.VALIDATION_ERROR);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    @Test
    void verifyRide_ShouldThrowException_WhenQrCodeIsNull() {
        // When & Then
        assertThatThrownBy(() -> rideService.verifyRide(1L, null))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.VALIDATION_ERROR);

        verify(rideRepository, never()).save(any(Ride.class));
    }

    @Test
    void verifyRide_ShouldThrowException_WhenQrCodeIsEmpty() {
        // When & Then
        assertThatThrownBy(() -> rideService.verifyRide(1L, ""))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", AppErrorCode.VALIDATION_ERROR);

        verify(rideRepository, never()).save(any(Ride.class));
    }
}
